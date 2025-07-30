##########################################################################

#Add-SingleUsertoEntraGroup.ps1
#Author : Sujin Nelladath
#LinkedIn : https://www.linkedin.com/in/sujin-nelladath-8911968a/

############################################################################

#Connect to Microsoft Graph
Connect-Graph -Scopes "GroupMember.ReadWrite.All", "User.ReadWrite.All" 


# Define Microsoft Graph API endpoint
$GraphBaseURL = "https://graph.microsoft.com/v1.0"

# Function to get Group ID by name
function Get-GroupID {
    param ($GroupName)
    $GroupURL = "$GraphBaseURL/groups?`$filter=displayName eq '$GroupName'"
    $Group = Invoke-MgGraphRequest -Uri $GroupURL -Method GET 
    return $Group.value[0].id
    
}

# Function to get User ID by name
function Get-UserID {
    param ($UserName)
    $UserURL = "$GraphBaseURL/users?`$filter=displayName eq '$UserName'"
    $User = Invoke-MgGraphRequest -Uri $UserURL -Method GET
    return $User.value[0].id
}

# Prompt user for Group Name
$GroupName = Read-Host "Enter Intune group name"
$GroupName = $GroupName.Trim()
$GroupID = Get-GroupID -GroupName $GroupName

if (!$GroupID) 
    {
        Write-Host "Group not found. Exiting."; 
        exit   
    }

# Prompt user for Device Name
$UserName = Read-Host "Enter User name"
$UserID = Get-UserID -UserName $UserName
if (!$UserID)
    { 
        Write-Host "User not found. Exiting.";
        exit 
    }

# Add Device to Group
$AddMemberURL = "$GraphBaseURL/groups/$GroupID/members/`$ref"
$Body = @{ "@odata.id" = "$GraphBaseURL/directoryObjects/$UserID" } | ConvertTo-Json
Invoke-MgGraphRequest -Uri $AddMemberURL  -Method POST -Body $Body

Write-Host "User $UserName successfully added to group $GroupName"