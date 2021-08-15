# Summary
A PowerShell script that connects to Azure AD and retrieves a list of owners of devices with a given OS. The list of device owners is exported to a CSV file, and the users are added to a relevant Azure AD group. 

# Description
I wanted to be able to get a list of all the users of a specific OS type so that automated processes could be applied to those users and devices. For example, if there's a known issue affecting just Android devices, I can get a list of all the Android users and target a solution article to just those users, add them to a group that might apply specific policies to resolve the issue, etc. 

<img src="/CSV_Screenshot.png" alt="Screenshot of what the exported CSV looks like"/>

# Conclusion
This was mostly a quick practice project for me, and while writing it I also used Azure AD Connect to sync my personal on-prem AD environment with Azure AD to mimic the hybrid environment I work with at my day job. 