$files = @("admin.html", "index.html")
foreach ($f in $files) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw
        if ($content -match "<<<<<<<" -or $content -match ">>>>>>>" -or $content -match "=======") {
            Write-Output "CONFLICT FOUND IN $f"
        } else {
            Write-Output "No markers in $f"
        }
    }
}
