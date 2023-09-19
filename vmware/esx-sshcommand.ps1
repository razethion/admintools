#This script runs commands on ESXi hosts via plink. This example will suppress coredump and shell warnings using esxcli, and updates a local account's password
Start-Transcript -Append "log_$( get-date -f yyyy-MM-dd ).txt"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DefaultVIServerMode Single -Confirm:$false

$root = ""
$Passwd = ""

$user = ""
$pas = ""

$esxlist = ""

$cmd = "esxcli system settings advanced set -o /UserVars/SuppressCoredumpWarning -i 1"
$cmd1 = "esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1"

$plink = "C:\plink\plink.exe" #Provide the path of plink

$PlinkOptions = " -v -batch -pw $Passwd"

$remoteCommand = '"' + $cmd + '"'
$remoteCommand1 = '"' + $cmd1 + '"'

foreach ($esx in $esxlist)
{

    Connect-VIServer $esx -User $root -Password $Passwd

    Write-Host -Object "setting password on $esx"

    Set-VMHostAccount -UserAccount $root -Password $Passwd

    Write-Host -Object "starting ssh services on $esx"

    $sshstatus = Get-VMHostService  -VMHost $esx| where { $psitem.key -eq "tsm-ssh" }

    if ($sshstatus.Running -eq $False)
    {

        Get-VMHostService | where { $psitem.key -eq "tsm-ssh" } | Start-VMHostService
    }

    Write-Host -Object "Executing Command on $esx"

    $output = "echo y | " + $plink + " -v -pw " + $Passwd + " " + $root + "@" + $esx + " " + "exit" #this is needed to accept the host ssh key otherwise commands fail
    $output1 = $plink + $plinkoptions + " " + $root + "@" + $esx + " " + $remoteCommand
    $output2 = $plink + $plinkoptions + " " + $root + "@" + $esx + " " + $remoteCommand1

    Write-Host -Object "logon $esx"
    Write-Host -Object $output
    $message = Invoke-Expression -command $output
    Write-Host -Object "core $esx"
    Write-Host -Object $output1
    $message1 = Invoke-Expression -command $output1
    Write-Host -Object "shell $esx"
    Write-Host -Object $output2
    $message2 = Invoke-Expression -command $output2

    $message
    $message1
    $message2

}

Stop-Transcript
