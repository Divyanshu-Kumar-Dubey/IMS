$content = Get-Content "index.html"
$markerLine = $content | Where-Object { $_ -match ">>>>>>>75ed5b9" } | Select-Object -First 1
$markerIndex = [array]::IndexOf($content, $markerLine)

if ($markerIndex -gt 0) {
    # Keep lines before line 2208 (index 2207) and after the marker line.
    $newContent = $content[0..2206] + $content[($markerIndex + 1)..($content.Length - 1)]
    $newContent | Out-File "index.html" -Encoding utf8
    Write-Output "Cleaned up index.html. Removed from index 2207 to $markerIndex."
} else {
    Write-Output "Marker not found or index too low: $markerIndex"
}
