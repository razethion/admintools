### This script will read a CSV file and for every sAMAccountName in the `ID` column it will output the associated displayname. This is especially useful for companies that use GIDs for accounts.
# Import the Active Directory module if not already imported
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Define the path to the CSV file
$csvFile = "<path>"

# Read the CSV file into a variable
$csvData = Import-Csv -Path $csvFile

# Loop through each row in the CSV
foreach ($row in $csvData) {
    # Retrieve the ID from the first column (replace 'ID' with the actual column name if different)
    $id = $row.ID
    
    # Query Active Directory to find the user with the specified ID
    # Replace 'sAMAccountName' with the appropriate attribute if your ID is not the sAMAccountName
    $user = Get-ADUser -Filter { sAMAccountName -eq $id } -Properties DisplayName
    
    # Check if the user was found
    if ($user -ne $null) {
        # Output the ID and user's DisplayName side by side
        Write-Host "$id`t$($user.DisplayName)"
    } else {
        # Output the ID and indicate that no user was found
        Write-Host "$id`tUser not found"
    }
}
