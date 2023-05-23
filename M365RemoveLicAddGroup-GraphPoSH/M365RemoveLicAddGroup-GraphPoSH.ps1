<#
.SYNOPSIS
    Removes an M/O365 directly assigned license from a user and assigns the user to a secuirty group
.DESCRIPTION
    Parses Users.csv for license change
.NOTES
    PREREQUISITES

    PoSH 7 or PoSH 5.1 
    Check PoSh version: $PSVersiontable
        PowerShell 7 https://github.com/PowerShell/PowerShell/releases/tag/v7.3.4
        
        PowerShell 5.1
            .NET 4.7.2 or later
            Check .NET version: https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
            https://support.microsoft.com/en-us/topic/microsoft-net-framework-4-8-offline-installer-for-windows-9d23f658-3b97-68ab-d013-aa3c3e7495e0
            PowerShellGet https://learn.microsoft.com/en-us/powershell/gallery/powershellget/update-powershell-51?view=powershellget-2.x
            Set-ExecutionPolicy RemoteSigned
        
        Install Graph PowerShell SDK 
        Install-Module Microsoft.Graph -Scope CurrentUser -AllowClobber -Force

    String IDs for M365 Service plans can be found at the following uRL
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
    
    Credit to: https://azurecloudai.blog/2023/05/04/assign-m365-license-via-graph-powershell-sdk/

    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    This script parses Users.csv unnassign a subscription. csv must be in the format
UserPricipalName
fred@domain.com
.LINK
    
.EXAMPLE 
#>
Connect-mgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"

# Define the security group's object ID
$securityGroupName = "Basic Security"
# Define the license to remove - use link in the description for product service plan string ID
$skuPartNumber = "SPB"

# Get the Security Group Id
$securityGroup = get-mggroup -filter "displayname eq '$securityGroupName'"
if ($securityGroup -ne $null) {
        $securityGroupObjectId = $securityGroup.Id
    Write-Host "Security Group Object ID: $securityGroupObjectId"
} else {
    Write-Host "Security group not found."
}

#Get license Id
$RemoveLicense = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $skuPartNumber

Import-csv Users.csv | foreach { 
	$userUPN = $_.UserPrincipalName 
    # Assign usage location United States if field UsageLocation empty
    $userObject = get-mguser -consistencylevel eventual -filter "startsWith(UserPrincipalName,'$userUPN')"
    if($userObject -ne $null){
    if($userObject.UsageLocation -eq $null){
        try{
            Update-MgUser -UserId $userObject.Id -UsageLocation "US"
            Write-Host "Usage Location for user $($userUPN) was not set. Added Usage Location US to the user!" -ForegroundColor "Yellow"
        }catch{
            Write-Host "Unable to set usage location for the user $($userUPN)" -ForegroundColor "Red"
            continue
        }
    }

    #Remove License
    try{
        Set-MgUserLicense -UserId $userObject.Id -AddLicenses @{} -RemoveLicenses @($RemoveLicense.SkuId)
        Write-Host "Removed ($RemoveLicense.SkuPartNumber) license for ($userUPN)" -ForegroundColor "Green"
     }catch{
         Write-Host "Unable to remove ($RemoveLicense.SkuPartNUmber) from ($userUPN)"
         #$userUPN | Out-File -FilePath $RemovedFailReport -Append
         continue
     }
     #Add User to Security Group
    try{
        $userObjectId = $userObject.Id
        New-mgGroupMember -GroupId $securityGroupObjectId -DirectoryObjectId $userObjectId
        Write-Host "Added ($userUPN) to group ($securityGroupName)" -ForegroundColor "Green"
    }catch{
        Write-Host "Unable to add ($userUPN) to group ($securityGroupName)" -ForegroundColor "Red"
        continue
    }
    } 
}