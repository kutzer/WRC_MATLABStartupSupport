# Define the username to remove
$target_username = "USERNAME"

# Get the currently signed-in users
$logged_in_users = quser

# Output the list of signed-in usernames, excluding the target username
$logged_in_users | ForEach-Object {
    # Use regex to extract the username from each line of output
    if ($_ -match '([^\s]+)\s+') {
        $username = $Matches[1]
        # Check if the username matches the target username
        if ($username -ne $target_username) {
            Write-Host $username
        }
    }
}