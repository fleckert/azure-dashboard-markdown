# azure-dashboard-markdown

[Azure Portal Dashboards](https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards) provide several widgets and out of the box tooling.

If you are facing functionality limits or do not want to use a public url for the Markdown Tile, the following snippet might be for you.

# Solution
- Deploy an AzurePortal Dashboard with a Markdown tile without dependencies.

# Usage

```powershell
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
```

# Links
- https://learn.microsoft.com/en-us/cli/azure/portal/dashboard
- https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards-structure
- https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-markdown-tile