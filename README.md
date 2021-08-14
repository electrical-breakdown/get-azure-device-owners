# Summary
A PowerShell script that connects to Azure AD and retrieves a list of owners of compliant devices with the specified OS. The list of device owners is exported to a CSV file, and the users are added to a relevant Azure AD group. 

# Description
I wanted to be able to get a list of all the users of a specific OS type so that automated processes could be applied to those users and devices. For example, if there's a known issue affecting just Android devices, I can get a list of all the Android users and target a notification to just those users, and/or add them to a group that might apply specific policies to resolve an issue. 

# Summary
This was mostly a practice project for me, and my current role generally doesn't permit me to put scripts into productoin if they write to AD/Azure. 

While writing this script I also gained the experience of using Azure AD Connect to sync my virtual on-prem AD environment with Azure AD to mimic the hybrid environment I work with at my day job. 