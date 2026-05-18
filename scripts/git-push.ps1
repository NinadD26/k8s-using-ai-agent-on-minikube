# ============================================================
# git-push.ps1 — Stage, commit, and push all repo changes
# Usage: .\git-push.ps1
#        .\git-push.ps1 -Message "your custom commit message"
# ============================================================

param(
    [string]$Message = "feat: add k8s guestbook manifests, scripts, screenshots and README"
)

# Ensure we're in the repo root
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

Write-Host "`n[1/4] Current git status:" -ForegroundColor Cyan
git status

Write-Host "`n[2/4] Staging all changes..." -ForegroundColor Cyan
git add .

Write-Host "`n[3/4] Committing with message: '$Message'" -ForegroundColor Cyan
git commit -m $Message

Write-Host "`n[4/4] Pushing to origin main..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Push successful!" -ForegroundColor Green
    Write-Host "   View at: https://github.com/NinadD26/k8s-using-ai-agent-on-minikube" -ForegroundColor Yellow
} else {
    Write-Error "Push failed. Check your SSH key or remote URL."
}
