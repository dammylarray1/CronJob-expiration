# check_expiration.ps1 - Checks for expiring images in Quay repository

# Define Quay API URL and repository details
$QuayApiUrl = "https://quay.io/api/v1/repository"
$QuayNamespace = "your_org"
$RepositoryName = "your_repo"
$ApiToken = $env:QUAY_API_TOKEN  # Securely passed as an environment variable

# Days before expiration to trigger an alert
$AlertThresholdDays = 7

# Function to get images nearing expiration
function Get-ExpiringImages {
    $Headers = @{
        Authorization = "Bearer $ApiToken"
    }
    $Url = "$QuayApiUrl/$QuayNamespace/$RepositoryName/tag/"

    # Send a GET request to the Quay API
    $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get

    # Check if the request was successful
    if ($Response -ne $null) {
        $ExpiringImages = @()
        foreach ($Tag in $Response.tags) {
            if ($Tag.expiration -ne $null) {
                # Calculate days to expiration
                $ExpirationDate = [datetime]::FromFileTimeUtc($Tag.expiration * 10000000)
                $DaysToExpire = ($ExpirationDate - (Get-Date)).Days
                if ($DaysToExpire -le $AlertThresholdDays) {
                    # Collect tags nearing expiration
                    $ExpiringImages += [pscustomobject]@{
                        Tag          = $Tag.name
                        DaysToExpire = $DaysToExpire
                    }
                }
            }
        }
        return $ExpiringImages
    } else {
        Write-Output "Failed to fetch tags from Quay."
        return $null
    }
}

# Main execution
$ExpiringImages = Get-ExpiringImages
if ($ExpiringImages -ne $null -and $ExpiringImages.Count -gt 0) {
    Write-Output "Images nearing expiration:"
    foreach ($Image in $ExpiringImages) {
        Write-Output ("Tag: {0} expires in {1} days" -f $Image.Tag, $Image.DaysToExpire)
    }
} else {
    Write-Output "No images nearing expiration."
}
