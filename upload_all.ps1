# ============================================================
# GitHub File Uploader — No Git Required, Uses GitHub REST API
# Pushes: index.html, favicon.png, 404.html, privacy.html, terms.html
# ============================================================
# HOW TO RUN:
#   1. Get a GitHub PAT at https://github.com/settings/tokens/new (tick 'repo')
#   2. Run: powershell -ExecutionPolicy Bypass -File "D:\For Website\upload_all.ps1"
#   3. When prompted, paste your PAT and press Enter
# ============================================================

$TOKEN  = Read-Host "Paste your GitHub Personal Access Token (PAT)"
$OWNER  = "Divyanshu-Kumar-Dubey"
$REPO   = "IMS"
$BRANCH = "main"
$DIR    = "D:\For Website"

$headers = @{
    Authorization = "token $TOKEN"
    Accept        = "application/vnd.github.v3+json"
    "User-Agent"  = "IMSUploader/1.0"
}

function Upload-File {
    param([string]$LocalPath, [string]$RemotePath, [string]$Msg)
    Write-Host "`n--- Uploading: $RemotePath ---" -ForegroundColor Yellow
    $bytes = [System.IO.File]::ReadAllBytes($LocalPath)
    $b64   = [Convert]::ToBase64String($bytes)
    $url   = "https://api.github.com/repos/$OWNER/$REPO/contents/$RemotePath"
    # Get existing SHA if file exists
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop
        $sha = $existing.sha
        Write-Host "  Updating existing file (sha: $sha)" -ForegroundColor Cyan
    } catch { Write-Host "  Creating new file" -ForegroundColor Green }
    $body = @{ message = $Msg; content = $b64; branch = $BRANCH }
    if ($sha) { $body.sha = $sha }
    try {
        $result = Invoke-RestMethod -Uri $url -Headers $headers -Method Put `
            -Body ($body | ConvertTo-Json -Depth 5) -ContentType "application/json" -ErrorAction Stop
        Write-Host "  SUCCESS: $($result.content.html_url)" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========== IMS GitHub Uploader ==========" -ForegroundColor Magenta

Upload-File "$DIR\index.html"   "index.html"   "feat: Add favicon, GA4, contact form, footer privacy/terms links"
Upload-File "$DIR\favicon.png"  "favicon.png"  "feat: Add IMS favicon"
Upload-File "$DIR\404.html"     "404.html"     "feat: Add custom branded 404 page"
Upload-File "$DIR\privacy.html" "privacy.html" "feat: Add Privacy Policy page"
Upload-File "$DIR\terms.html"   "terms.html"   "feat: Add Terms of Service page"

Write-Host "`n========== All done! ==========" -ForegroundColor Magenta
Write-Host "Visit https://imsjsr.com in a few minutes to see your updated site." -ForegroundColor White
Read-Host "`nPress Enter to exit"
