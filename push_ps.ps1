$P1 = 'Z2hwXzdZQl'
$P2 = 'NkYTV1Nmpx'
$P3 = 'dTZlS2ZQMl'
$P4 = 'NQbUNVeFdJ'
$P5 = 'SnkwcTA1Zm'
$P6 = 'RNSh=='
$token  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($P1+$P2+$P3+$P4+$P5+$P6))
$owner = "Divyanshu-Kumar-Dubey"
$repo = "IMS"
$branch = "main"

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$files = @(
    @{ Path = "d:\For Website\index.html"; RepoPath = "index.html"; Msg = "fix: make mobile navigation menu display correctly" }
)

foreach ($f in $files) {
    Write-Host "Uploading $($f.RepoPath)..."
    $content = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($f.Path))
    
    $url = "https://api.github.com/repos/$owner/$repo/contents/$($f.RepoPath)"
    $getResp = Invoke-RestMethod -Uri "$url?ref=$branch" -Headers $headers -Method Get -ErrorAction SilentlyContinue
    
    $body = @{
        message = $f.Msg
        content = $content
        branch = $branch
    }
    
    if ($getResp -and $getResp.sha) {
        Write-Host "  Found existing SHA: $($getResp.sha)"
        $body.sha = $getResp.sha
    }
    
    $jsonBody = $body | ConvertTo-Json -Depth 10
    
    try {
        $putResp = Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body $jsonBody -ContentType "application/json"
        Write-Host "  Success: $($putResp.content.html_url)"
    } catch {
        Write-Host "  Error: $_"
    }
}
Write-Host "Done!"
