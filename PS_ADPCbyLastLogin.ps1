Get-ADComputer -Filter * -Properties *  | Sort LastLogonDate | FT Name, LastLogonDate, OperatingSystem -Autosize | Out-File C:\Temp\ComputerLastLogonDate.txt
