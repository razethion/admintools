#This is a script to quickly configure common settings for a list of hosts right after install. These are specific to our environment, so you may want to change this for your environment.
#VARIABLES
$vcenter = ""
$esxihosts = "" #You can add more hosts by comma seperating them. "host1","host2","host3"

$rootpassword = '' #Fill in the esxi root password
$opspassword = '' #Fill in the esxi ops password

#Enter credentials for domain join and vcenter login
$waduser = ''
$wadpass = ''
#END VARIBLES

##################################
#create creds
$esxrootpw = ConvertTo-SecureString -String $rootpassword -AsPlainText -Force
$domainpw = ConvertTo-SecureString -String $wadpass -AsPlainText -Force

$esxcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'root', $esxrootpw
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $waduser, $domainpw

foreach ($esxihost in $esxihosts) {

#create ops account
Connect-VIServer -Server $esxihost -Credential $esxcred

New-VMHostAccount -UserAccount -id 'svc' -Password $opspassword -Server $esxihost
New-VIPermission -Entity $esxihost -Principal 'svc' -Role 'Admin'

#Switch to VC
Disconnect-VIServer -Confirm:$false
Connect-VIServer -Server $vcenter -Credential $domaincred

#Change ESXi admin group
Get-AdvancedSetting -Entity $esxihost -Name "Config.HostAgent.plugins.hostsvc.esxAdminsGroup" | Set-AdvancedSetting -Value 'ESXi_Admins' -Confirm:$false

#NTP setup
Add-VMHostNtpServer -NtpServer '' -VMHost $esxihost
Add-VMHostNtpServer -NtpServer '' -VMHost $esxihost
Add-VMHostNtpServer -NtpServer '' -VMHost $esxihost
Get-VMHostService -VMHost $esxiHost | Where { $_.Key -eq 'ntpd' } | Restart-VMHostService -Confirm:$false

#Domain join
Get-VMHostAuthentication -Server $esxihost | Set-VMHostAuthentication -Domain '' -Credential $domaincred -JoinDomain:$true -Confirm:$false

#Networking setup
$esxip = Get-VMHost -Name $esxihost | Select @{n="ManagementIP"; e={Get-VMHostNetworkAdapter -VMHost $_ -VMKernel | ?{$_.ManagementTrafficEnabled} | %{$_.Ip}}}
$octet = (Select-String -InputObject $esxip.ManagementIP.toString() -Pattern "([0-9]+)$" -AllMatches).Matches | Foreach-Object {$_.Groups[1].Value}

$vSwitch = "vSwitch0"
$mtu = 9000

$vmotionpg = "vmk-vmotion-a"
$vmotionvl = 123
$vmotionip = "0.0.0." + $octet
$vmotionsm = "255.255.255.0"

#Remove unnessecary networks
Get-VirtualPortGroup -VMHost $esxihost -Name 'VM Network' | Remove-VirtualPortGroup -Confirm:$false
Get-VirtualSwitch -VMHost $esxihost -Name 'vSwitchBMC' | Remove-VirtualSwitch -Confirm:$false

#Create VMotion network
New-VMHostNetworkAdapter -VMHost $esxihost -PortGroup $vmotionpg -VirtualSwitch $vSwitch  -IP $vmotionip -SubnetMask $vmotionsm -MTU $mtu
Get-VirtualPortGroup -VMHost $esxihost -Name $vmotionpg | Set-VirtualPortGroup -VlanId $vmotionvl
Get-VMHostNetworkAdapter -VMHost $esxihost | Where-Object {$_.PortGroupName -eq $vmotionpg} | Set-VMHostNetworkAdapter -VMotionEnabled $true

Disconnect-VIServer -Confirm:$false
}
