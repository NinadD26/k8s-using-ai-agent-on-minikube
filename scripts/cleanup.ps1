# ============================================================
# cleanup.ps1 — Tear down the Guestbook deployment
# Usage: .\scripts\cleanup.ps1
#        .\scripts\cleanup.ps1 -StopMinikube   (also stops Minikube)
# ============================================================

param(
    [switch]$StopMinikube
)

$NAMESPACE = "guestbook"

Write-Host "`n[1/2] Deleting namespace '$NAMESPACE' and all resources inside it..." -ForegroundColor Cyan
kubectl delete namespace $NAMESPACE --ignore-not-found=true

if ($StopMinikube) {
    Write-Host "`n[2/2] Stopping Minikube..." -ForegroundColor Cyan
    minikube stop
    Write-Host "✅ Minikube stopped." -ForegroundColor Green
} else {
    Write-Host "`n[2/2] Minikube left running. Use 'minikube stop' to stop it manually." -ForegroundColor Yellow
}

Write-Host "`n✅ Cleanup complete!" -ForegroundColor Green
