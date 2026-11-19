Set-Location 'C:\Users\hp\Documents\Projects\Awesome-Web-Scraping-Chatbot-Infrastructure'
$loops_path = $env:loops_path
$repo_name = if ([string]::IsNullOrEmpty($env:repo_name)) { (Get-Item .).Name } else { $env:repo_name }

git pull
git add assets/banner.svg
git commit -m "banner"
git push origin (git branch --show-current)

$repo_name = if ([string]::IsNullOrEmpty($env:repo_name)) { (Get-Item .).Name } else { $env:repo_name }
git pull

if (Test-Path "node_modules") { Remove-Item -Force -Recurse node_modules/* -ErrorAction SilentlyContinue }
if (Test-Path "scratch") { Remove-Item -Force -Recurse scratch/* -ErrorAction SilentlyContinue }
Get-ChildItem -Filter *.py -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Filter *.ps1 -Exclude "run_cleanup.ps1" -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Filter *.txt -ErrorAction SilentlyContinue | Remove-Item -Force

git status --porcelain | ForEach-Object {
    $parts = $_ -split '\s+', 2
    $f = $parts[1]
    if ($f -and (Test-Path $f)) {
        git add $f
        git commit -m "Chg: $f"
    }
}
git push origin (git branch --show-current)
git diff --name-only | ForEach-Object {
    git commit -m "Update $_" $_
}
git push origin (git branch --show-current)

$real_repo_name = $repo_name.Replace('Awesome-','')

(Get-Content -Path "./README.md") -replace "GitHub Stars", "GitHub_Stars" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace "Github Stars", "GitHub_Stars" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace "Stars Badge", "Stars_Badge" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace "Star Badge", "Stars_Badge" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace "Stars Count", "Stars_Count" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace "Star Count", "Stars_Count" | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace " Stars ", " GitHub_Stars " | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace '\| Stars \|', '| GitHub_Stars |' | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace '\| Stars ', '| GitHub_Stars ' | Set-Content -Path "./README.md"
(Get-Content -Path "./README.md") -replace '\|  Stars ', '|  GitHub_Stars ' | Set-Content -Path "./README.md"

try {
    github-growth-plot --publish
} catch {
    Write-Host "github-growth-plot notice: $_"
}

git add README.md
git add assets
git commit -m "final readme"
git -c http.sslVerify=false push
git status

if (-not (Test-Path "assets\social-preview.gif")) {
    try {
        svg2gif -s 1.0
    } catch {
        Write-Host "svg2gif notice: $_"
    }
}
