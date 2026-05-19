# Sample Output

This folder contains sample output files demonstrating the shape of data
emitted by the scripts in this repository. Real values have been replaced
with representative placeholders.

| File | Produced by |
|------|-------------|
| `sample-system-health.json` | `Get-SystemHealth.ps1 \| ConvertTo-Json -Depth 4` |
| `sample-disk-report.csv` | `Get-DiskReport.ps1 -ExportPath ...` |

These files are also useful as a reference when writing scripts or
dashboards that consume the output.
