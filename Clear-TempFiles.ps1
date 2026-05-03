# Clear-TempFiles.ps1
# Cleans up temporary files to free disk space
# Run as Administrator

Write-Host "===== Temp File Cleanup =====" -ForegroundColor Cyan

$paths = @(
    $env:TEMP,
    $env:TMP,
    "C:\Windows\Temp",
    "C:\Windows\Prefetch"
)

$totalFreed = 0

foreach ($path in $paths) {
    if (Test-Path $path) {
        $before = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        $after  = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freed  = [math]::Round((($before - $after) / 1MB), 2)
        $totalFreed += $freed
        Write-Host "Cleaned: $path  | Freed: $freed MB" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Total space freed: $([math]::Round($totalFreed, 2)) MB" -ForegroundColor Green
