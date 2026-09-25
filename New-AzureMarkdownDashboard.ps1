<#
.SYNOPSIS
    Creates an Azure Portal dashboard containing a single markdown tile.

.DESCRIPTION
    Builds an Azure dashboard definition with one MarkdownPart tile and deploys it
    with the Azure CLI ('az portal dashboard create'). The 'portal' CLI extension is
    installed automatically (allowing previews) if it is missing, and the target
    resource group is created if it does not already exist.

    Dashboard structure reference:
      https://learn.microsoft.com/azure/azure-portal/azure-portal-dashboards-structure
    Markdown tile reference:
      https://learn.microsoft.com/azure/azure-portal/azure-portal-markdown-tile
    CLI reference:
      https://learn.microsoft.com/cli/azure/portal/dashboard

.PARAMETER SubscriptionId
    The GUID of the Azure subscription to deploy the dashboard into.

.PARAMETER ResourceGroupName
    Name of the resource group that will contain the dashboard. Created if missing.

.PARAMETER Location
    Azure region used when the resource group has to be created and for the dashboard.

.PARAMETER DashboardName
    Name of the dashboard resource to create.

.PARAMETER MarkdownTitle
    Title shown at the top of the markdown tile.

.PARAMETER MarkdownSubTitle
    Subtitle shown below the title of the markdown tile.

.PARAMETER MarkdownContent
    Markdown text rendered inside the tile.

.PARAMETER MarkdownDimensionsRows
    Height of the markdown tile expressed in dashboard grid rows (rowSpan).

.PARAMETER MarkdownDimensionsColumns
    Width of the markdown tile expressed in dashboard grid columns (colSpan).

.EXAMPLE
    ./New-AzureMarkdownDashboard.ps1                                     `
        -SubscriptionId           '00000000-0000-0000-0000-000000000000' `
        -ResourceGroupName        'rg-dashboards'                        `
        -Location                 'westeurope'                           `
        -DashboardName            'my-dashboard'                         `
        -MarkdownTitle            'Welcome'                              `
        -MarkdownSubTitle         'Team overview'                        `
        -MarkdownContent          '# Hello'                              `
        -MarkdownDimensionsRows    4                                     `
        -MarkdownDimensionsColumns 6

.NOTES
    Requires the Azure CLI to be installed and an authenticated session (az login).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]                           [guid  ] $SubscriptionId        ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $ResourceGroupName     ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $Location              ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $DashboardName         ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $MarkdownTitle         ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $MarkdownSubTitle      ,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()] [string] $MarkdownContent       ,
    [Parameter(Mandatory)]                           [int   ] $MarkdownDimensionsRows,
    [Parameter(Mandatory)]                           [int   ] $MarkdownDimensionsColumns
)

$portalExtension = az extension show --name portal 2>$null

if (-not $portalExtension) {
	az extension add --name portal --allow-preview true
}

$resourceGroup = az group show --subscription $SubscriptionId --name $ResourceGroupName 2>$null

if (-not $resourceGroup ) {
    az group create --subscription $SubscriptionId --name $ResourceGroupName --location $Location
}

$dashboard = @{
    lenses = @(
        @{
            order = 0
            parts = @(
                @{
                    position = @{ x = 0; y = 0; rowSpan = $MarkdownDimensionsRows; colSpan = $MarkdownDimensionsColumns }
                    metadata = @{
                        type = 'Extension/HubsExtension/PartType/MarkdownPart'
                        inputs = @()
                        settings = @{
                            content = @{
                                settings = @{
                                    title    = $MarkdownTitle
                                    subtitle = $MarkdownSubTitle
                                    content  = $MarkdownContent
                                }
                            }
                        }
                    }
                }
            )
        }
    )
    metadata = @{}
}

$dashboardJson = $dashboard | ConvertTo-Json -Depth 100
$inputPath = New-TemporaryFile
Set-Content -Path $inputPath -Value $dashboardJson -Encoding utf8

try {
    az portal dashboard create              `
        --subscription $SubscriptionId      `
        --resource-group $ResourceGroupName `
        --name $DashboardName               `
        --location $Location                `
        --input-path $inputPath
}
finally {
    Remove-Item -Path $inputPath -Force
}
