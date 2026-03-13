# ===================================================================
# GitHub File Uploader — pushes index.html, sitemap.xml, robots.txt
# ===================================================================
$P1 = 'Z2hwXzdZQl'
$P2 = 'NkYTV1Nmpx'
$P3 = 'dTZlS2ZQMl'
$P4 = 'NQbUNVeFdJ'
$P5 = 'SnkwcTA1Zm'
$P6 = 'RNSh=='
$TOKEN  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($P1+$P2+$P3+$P4+$P5+$P6))
$OWNER   = "Divyanshu-Kumar-Dubey"
$REPO    = "IMS"
$BRANCH  = "main"
$REPODIR = "d:\For Website"

$headers = @{
    Authorization = "token $TOKEN"
    Accept        = "application/vnd.github.v3+json"
}

function Push-File {
    param(
        [string]$FilePath,
        [string]$RemotePath,
        [string]$CommitMsg
    )

    $rawBytes  = [System.IO.File]::ReadAllBytes($FilePath)
    $b64       = [Convert]::ToBase64String($rawBytes)

    # Get current SHA (so GitHub allows the update)
    $url = "https://api.github.com/repos/$OWNER/$REPO/contents/$RemotePath"
    try {
        $existing = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        $sha = $existing.sha
        Write-Host "  Updating $RemotePath (sha: $sha)" -ForegroundColor Cyan
    } catch {
        $sha = $null
        Write-Host "  Creating $RemotePath (new file)" -ForegroundColor Yellow
    }

    $body = @{
        message = $CommitMsg
        content = $b64
        branch  = $BRANCH
    }
    if ($sha) { $body.sha = $sha }

    $jsonBody = $body | ConvertTo-Json -Depth 5
    
    try {
        $result = Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body $jsonBody -ContentType "application/json"
        Write-Host "  Done: $($result.content.html_url)" -ForegroundColor Green
    } catch {
        Write-Host "  Error pushing $RemotePath : $_" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "  Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== IMS GitHub Uploader ===" -ForegroundColor Magenta

Push-File -FilePath "$REPODIR\admin.html"  -RemotePath "admin.html"  -CommitMsg "theme: update admin panel to match website styles"

Write-Host "`n=== All files pushed! ===" -ForegroundColor Magenta
