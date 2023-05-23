# M365LicenseScripts
A collection of scripts to manipulate M365 licensing using the new Microsoft Graph PowerShell.<br><br>
Azure AD PowerShell and MSOnline APIs are slated for deprecation at this time, Q1/2023. So we need to adopt MS' latest Graph Powershell. Isn't MS grand?<br><br>
## Prerequisites
PoSH 7 or PoSH 5.1<br>
Check PoSh version: $PSVersiontable<br>
1. PowerShell 7 https://github.com/PowerShell/PowerShell/releases/tag/v7.3.4<br>
2. PowerShell 5.1 <br>
    - .NET 4.7.2 or later <br>
    - Check .NET version: https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed<br>
    - https://support.microsoft.com/en-us/topic/microsoft-net-framework-4-8-offline-installer-for-windows-9d23f658-3b97-68ab-d013-aa3c3e7495e0 <br>
    - PowerShellGet https://learn.microsoft.com/en-us/powershell/gallery/powershellget/update-powershell-51?view=powershellget-2.x <br>
    - Set-ExecutionPolicy RemoteSigned<br><br>

Install Graph PowerShell SDK <br>
Install-Module Microsoft.Graph -Scope CurrentUser -AllowClobber -Force<br>

String IDs for M365 Service plans can be found at the following uRL<br>
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference<br><br>
    
### ref:<br>
 https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-licensing-whatis-azure-portal
