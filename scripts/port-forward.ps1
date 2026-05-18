# ============================================================
# port-forward.ps1 — Port-forward frontend service to localhost:8080
# Usage: .\scripts\port-forward.ps1
# Note: Keep this terminal open while accessing the app.
# ============================================================

$NAMESPACE = "guestbook"

Write-Host "`n[INFO] Checking pod status in namespace '$NAMESPACE'..." -ForegroundColor Cyan
kubectl get pods -n $NAMESPACE

Write-Host "`n[INFO] Starting port-forward: localhost:8080 -> frontend service port 80" -ForegroundColor Cyan
Write-Host "       Open http://localhost:8080 in your browser." -ForegroundColor Yellow
Write-Host "       Press Ctrl+C to stop.`n" -ForegroundColor Yellow

kubectl port-forward svc/frontend 8080:80 -n $NAMESPACE
