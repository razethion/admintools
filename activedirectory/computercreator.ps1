# This batch creates computer objects based on a prefix array
$count = 16
$start = 1
$server = "servername"
while ($start -le $count)
{
    
    $samname = $server + ('{0:d2}' -f $start)
    $hostname =  $samname + ".fullyqualified.domainname"
    echo "Creating $samname"

    New-ADComputer -DNSHostName $hostname -Name $samname -SAMAccountName $samname -Path "DC=servers,DC=fullyqualified,DC=domainname"
    Set-ADComputer -Identity $samname -Description $hostname

    $start++

}
