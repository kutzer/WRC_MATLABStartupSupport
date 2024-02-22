# Get the current username
$username = $env:USERNAME

# Execute query user command to get session information
$queryUserInfo = query user $username

Write-Output $queryUserInfo