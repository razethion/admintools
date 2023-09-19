### This script will batch restart a service on an array of servers, in this example is restarts 'TermService' which forces a renewal of the SSL certificate tied to remote desktop if it expires soon.
# Define the array of server names
#$servers = @('')

# Define the service name
$serviceName = 'SessionEnv'  # 'TermService' is the service name for Remote Desktop Services 

# Iterate over the servers
foreach ($server in $servers) {
    # Use a try-catch block to handle potential errors
    try {
        # Get the status of the service
        $service = Get-Service -ComputerName $server -Name $serviceName

        # Check if the service is running
        if ($service.Status -eq 'Running') {
            # Restart the service
            Restart-Service -InputObject $service -Force

            # Print a success message
            Write-Host "Successfully restarted $serviceName on $server."
        } else {
            # Print a message if the service is not running
            Write-Host "$serviceName is not running on $server."
        }
    } catch {
        # Print an error message if an error occurs
        Write-Host "Failed to restart $serviceName on $server. Error details: $($_.Exception.Message)"
    }
}
