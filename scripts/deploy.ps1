# ============================================================
# deploy.ps1 — Deploy Guestbook app to Minikube
# Usage: .\scripts\deploy.ps1
# ============================================================

$NAMESPACE = "guestbook"
$MANIFESTS  = "$PSScriptRoot\..\manifests"

Write-Host "`n[1/5] Starting Minikube with Docker driver..." -ForegroundColor Cyan
minikube start --driver=docker
if ($LASTEXITCODE -ne 0) { Write-Error "Minikube failed to start."; exit 1 }

Write-Host "`n[2/5] Creating namespace '$NAMESPACE'..." -ForegroundColor Cyan
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

Write-Host "`n[3/5] Applying all manifests..." -ForegroundColor Cyan
$files = @(
    "redis-leader-deployment.yaml",
    "redis-leader-service.yaml",
    "redis-follower-deployment.yaml",
    "redis-follower-service.yaml",
    "frontend-deployment.yaml",
    "frontend-service.yaml"
)
foreach ($f in $files) {
    Write-Host "  -> Applying $f"
    kubectl apply -f "$MANIFESTS\$f" -n $NAMESPACE
}

Write-Host "`n[4/5] Waiting for all pods to be ready (timeout 120s)..." -ForegroundColor Cyan
kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=120s

Write-Host "`n[5/5] Pod status:" -ForegroundColor Cyan
kubectl get pods -n $NAMESPACE

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "   Run .\scripts\port-forward.ps1 to access the app at http://localhost:8080" -ForegroundColor Yellow
