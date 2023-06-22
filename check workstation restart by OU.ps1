# Specify the distinguished name of the OU to check
$ouDN = "OU=Computers,DC=gmail,DC=com,"
$NewName =($ouDN -split ",")[1]
$NewOU = $ouDN -replace $NewName, "<EachName>"
$OUName = ($NewOU -split ",")[1] 

# Get a list of computers in the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ouDN | Select-Object -ExpandProperty Name

# Get the current time and the time 48 hours ago
$now = Get-Date
$hoursAgo = $now.AddHours(-24)

# Create a variable to store the log file path and name
$logFilePath = "D:\restarts In $OUName at Last 24 hours.txt"

# Loop through each computer and check the number of restarts in the last 48 hours
foreach ($computer in $computers) {
    $restarts = Get-WinEvent -ComputerName $computer -FilterHashtable @{
        LogName = 'System'
        ID = 1074
        StartTime = $hoursAgo
        EndTime = $now
    } | Measure-Object | Select-Object -ExpandProperty Count
    $logMessage = "$computer has been restarted $restarts times in the last 24 hours."
    Write-Output $logMessage
    Add-Content -Path $logFilePath -Value $logMessage
}