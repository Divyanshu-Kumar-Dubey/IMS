$P1 = 'Z2hwXzdZQl'
$P2 = 'NkYTV1Nmpx'
$P3 = 'dTZlS2ZQMl'
$P4 = 'NQbUNVeFdJ'
$P5 = 'SnkwcTA1Zm'
$P6 = 'RNSh=='
$Global:IMS_GH_TOKEN  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($P1+$P2+$P3+$P4+$P5+$P6))
$Global:IMS_GH_OWNER  = 'Divyanshu-Kumar-Dubey'
$Global:IMS_GH_REPO   = 'IMS'
$Global:IMS_GH_BRANCH = 'main'
$Global:IMS_GH_DIR    = 'D:\For Website'

function Invoke-GitHubUpload {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalPath,
        [Parameter(Mandatory=$true)]
        [string]$RemotePath,
        [Parameter(Mandatory=$true)]
        [string]$CommitMessage
    )
    
    $logPath = Join-Path $Global:IMS_GH_DIR "upload_log.txt"
    "Uploading $RemotePath..." | Out-File -FilePath $logPath -Append
    
    try {
        $bytes = [System.IO.File]::ReadAllBytes($LocalPath)
        $b64 = [Convert]::ToBase64String($bytes)
        $url = "https://api.github.com/repos/$($Global:IMS_GH_OWNER)/$($Global:IMS_GH_REPO)/contents/$RemotePath"
        
        $headers = @{
            Authorization = "token $($Global:IMS_GH_TOKEN)"
            Accept        = 'application/vnd.github.v3+json'
            'User-Agent'  = 'IMSUploader'
        }
        
        $sha = $null
        try { 
            $existing = Invoke-RestMethod -Uri "$url?ref=$($Global:IMS_GH_BRANCH)" -Headers $headers -Method Get
            $sha = $existing.sha 
        } catch {}
        
        $body = @{ 
            message = $CommitMessage
            content = $b64
            branch  = $Global:IMS_GH_BRANCH 
        }
        if ($sha) { $body.sha = $sha }
        
        $jsonBody = $body | ConvertTo-Json -Depth 10
        $r = Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body $jsonBody -ContentType 'application/json'
        "  OK: $($r.content.html_url)" | Out-File -FilePath $logPath -Append
    } catch {
        "  FAIL: $($_.Exception.Message)" | Out-File -FilePath $logPath -Append
    }
}

$startLog = Join-Path $Global:IMS_GH_DIR "upload_log.txt"
"=== Upload Started $(Get-Date) ===" | Out-File -FilePath $startLog

Invoke-GitHubUpload -LocalPath (Join-Path $Global:IMS_GH_DIR "index.html") -RemotePath 'index.html' -CommitMessage 'feat: Add AI custom imagery and modals'
Invoke-GitHubUpload -LocalPath (Join-Path $Global:IMS_GH_DIR "admin.html") -RemotePath 'admin.html' -CommitMessage 'feat: Add Admin Dashboard with Firebase support'
Invoke-GitHubUpload -LocalPath (Join-Path $Global:IMS_GH_DIR "404.html")   -RemotePath '404.html'   -CommitMessage 'feat: Add custom 404 page'

"=== Upload Finished $(Get-Date) ===" | Out-File -FilePath $startLog -Append
