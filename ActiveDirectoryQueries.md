# AD Queries

### List Domain Admins
	(&(memberOf=CN=Domain Admins,CN=Users,DC=domain,dc=local))
	
### List Members of Group
	(&(memberOf=CN=groupname,OU=OUname,OU=OUname,DC=domain,dc=local))

### List all persons with description of Employee
	(&(objectCategory=person)(objectClass=user)(description=Employee))
