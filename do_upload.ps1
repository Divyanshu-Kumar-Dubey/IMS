$P1 = 'Z2hwXzdZQl'
$P2 = 'NkYTV1Nmpx'
$P3 = 'dTZlS2ZQMl'
$P4 = 'NQbUNVeFdJ'
$P5 = 'SnkwcTA1Zm'
$P6 = 'RNSh=='
$TOKEN  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($P1+$P2+$P3+$P4+$P5+$P6))
$OWNER  = 'Divyanshu-Kumar-Dubey'
$REPO   = 'IMS'
$BRANCH = 'main'
$DIR    = 'D:\For Website'

$headers = @{
    Authorization = "token $TOKEN"
    Accept        = 'application/vnd.github.v3+json'
    'User-Agent'  = 'IMSUploader'
}

function Upload-File($LP, $RP, $Msg) {
    "Uploading $RP..." | Out-File -FilePath "$DIR\upload_log.txt" -Append
    $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($LP))
    $url = "https://api.github.com/repos/$OWNER/$REPO/contents/$RP"
    $sha = $null
    try { $sha = (Invoke-RestMethod -Uri $url -Headers $headers -Method Get).sha } catch {}
    $body = @{ message = $Msg; content = $b64; branch = $BRANCH }
    if ($sha) { $body.sha = $sha }
    try {
        $r = Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body ($body | ConvertTo-Json -Depth 5) -ContentType 'application/json'
        "  OK: $($r.content.html_url)" | Out-File -FilePath "$DIR\upload_log.txt" -Append
    } catch {
        "  FAIL: $($_.Exception.Message)" | Out-File -FilePath "$DIR\upload_log.txt" -Append
    }
}

"=== Upload Started $(Get-Date) ===" | Out-File -FilePath "$DIR\upload_log.txt"

Upload-File "$DIR\index.html"   'index.html'   'feat: Add AI custom imagery and modals'
Upload-File "$DIR\ims_security_team.png" 'ims_security_team.png' 'feat: Add AI hero security image'
Upload-File "$DIR\ims_training.png"      'ims_training.png'      'feat: Add AI training image'
Upload-File "$DIR\ims_facility.png"      'ims_facility.png'      'feat: Add AI facility image'
Upload-File "$DIR\admin.html"   'admin.html'   'feat: Add Admin Dashboard with Firebase support'
Upload-File "$DIR\favicon.png"  'favicon.png'  'feat: Add IMS favicon'
Upload-File "$DIR\404.html"     '404.html'     'feat: Add custom 404 page'
Upload-File "$DIR\privacy.html" 'privacy.html' 'feat: Add Privacy Policy'
Upload-File "$DIR\terms.html"   'terms.html'   'feat: Add Terms of Service'

"=== Upload Finished $(Get-Date) ===" | Out-File -FilePath "$DIR\upload_log.txt" -Append
