git status | Out-File -FilePath status_debug_utf8.txt -Encoding utf8
git branch | Out-File -FilePath status_debug_utf8.txt -Encoding utf8 -Append
git log -1 | Out-File -FilePath status_debug_utf8.txt -Encoding utf8 -Append
