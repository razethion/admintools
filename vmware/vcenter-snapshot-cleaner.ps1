# This script automatically cleans up old snapshots and writes the deleted ones to a file

$vcenters = ""
$datacenters = ""

$CutoffDate = (get-date).AddDays(-30).Date

###----------------------------###

Start-Transcript -Append "log_$( get-date -f yyyy-MM-dd ).txt"
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false

$password = ConvertTo-SecureString "" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("", $password)

foreach ($listvc in $vcenters)
{
    Write-Output "Connecting to $listvc"
    Connect-VIServer -Server $listvc -Credential $cred
}

Write-Output "Getting vms and their snapshots"

$snapshots = @()
foreach ($datacenter in $datacenters)
{

    Write-Output "Checking datacenter $datacenter"
    $snapshots += Get-Datacenter -Name $datacenter | Get-VM | Get-Snapshot

}

Write-Output "Looping thru snapshot dates"
foreach ($snapshot in $snapshots)
{
    if ($snapshot.Created -lt $CutoffDate)
    {
        Write-Output "`n"
        Write-Output $snapshot.VM.ToString()
        Write-Output $snapshot.Created.ToString()
        Write-Output "Snapshot is old"
        $snapshot | Select-Object -Property VM, Created, Name, Description | Export-CSV `
            -Path "log_$( get-date -f yyyy-MM-dd ).csv" `
            -NoTypeInformation -Append
        Remove-Snapshot -Snapshot $snapshot -Confirm:$false -RunAsync:$true
    }
}

Write-Output "`n"
Write-Output done
Stop-Transcript
