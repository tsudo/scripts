# Title: Active Directory (AD) Queries

LastMod: 20200406

Keith S. Crawford // 
@tsudo on [Github](https://github.com/tsudo) & [Twitter](https://twitter.com/tsudo)

### List All Domain Users
`Get-ADUser -Filter * -SearchBase "DC=ad,DC=company,DC=com"`

### List All Domain Users, include email address
`Get-ADUser -Filter * -SearchBase "DC=ad,DC=company,DC=com" -Properties mail | Select mail | Export-CSV "Email Addresses.csv"`

### List All Users in OU
`Get-ADUser -Filter * -SearchBase "OU=Finance,OU=UserAccounts,DC=FABRIKAM,DC=COM"`

### List Members of AD SG
`Get-ADGroupMember -identity “Name of Group” | select name | Export-csv -path C:\Output\Groupmembers.csv -NoTypeInformation`
