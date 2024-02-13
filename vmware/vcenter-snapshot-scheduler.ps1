Install-Module -Name VMware.PowerCLI

Connect-VIServer -Server "vcenter.example.com"

#Create a csv with one column, titled vmname
Import-Csv -Path .\vmnames.csv -UseCulture -PipelineVariable row |
ForEach-Object -Process {

# Define VM name and snapshot name
$vmName = $($row.vmname)
$snapshotName = "Snapshot for $vmName"

echo "Creating task for $vmName"

# Specify the date and time for the snapshot
$snapshotTime = Get-Date "2024-02-17 21:30:00Z"

# Create a scheduled task to take a snapshot at the specified time
$vm = Get-View -ViewType VirtualMachine -Filter @{"Name"=$vmName}

$spec = New-Object VMware.Vim.ScheduledTaskSpec
$spec.Name = "Snapshot $($vm.Name)"
$spec.Description = "Snapshot $($vm.Name)"
$spec.Enabled = $true
$spec.Notification = "riley.magnuson@hyatt.com"
$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
$spec.Scheduler.runAt = $snapshotTime
$spec.Action = New-Object VMware.Vim.MethodAction
$spec.Action.Name = "CreateSnapshot_Task"
$arg1 = New-Object VMware.Vim.MethodActionArgument
$arg1.Value = "Snapshot $($vm.Name)"
$arg2 = New-Object VMware.Vim.MethodActionArgument
$arg2.Value = "Snapshot $($vm.Name)"
$arg3 = New-Object VMware.Vim.MethodActionArgument
$arg3.Value = $false
$arg4 = New-Object VMware.Vim.MethodActionArgument
$arg4.Value = $false
$spec.Action.Argument = $arg1,$arg2,$arg3,$arg4

# Create the snapshot task
$scheduledTaskManager = Get-View ScheduledTaskManager
$task = $scheduledTaskManager.CreateScheduledTask($vm.MoRef, $spec)

echo "Done task for $vmName"

}
