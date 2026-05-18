# 🤖 AI-Agent–Assisted Kubernetes Deployment (Cline + Minikube)

> Deploying the official Kubernetes **Guestbook** sample app on **Minikube** using **Cline** (AI agent in VS Code) with human-in-the-loop approvals at every step.

---

## 📸 Demo

| Cline Deploying | Pods Running | App Live |
|---|---|---|
| ![Cline deployment in VS Code](screenshots/04-cline-vscode-final.png) | ![All pods running](screenshots/01-deployment-status.png) | ![Guestbook app at localhost:8080](screenshots/03-guestbook-app-running.png) |

---

## 📖 What This Project Is

This repo demonstrates an **AI-in-the-loop DevOps workflow** where:

- An **AI agent (Cline)** handles all repetitive steps — fetching manifests, applying them, checking pod status, port-forwarding — via micro-step prompts
- A **human approves every command** before it runs (no auto-execute)
- The result is a **fully reproducible, documented** local Kubernetes deployment

The app deployed is the official **Guestbook** sample from the Kubernetes documentation:
- **Redis Leader** (1 replica) — primary write node
- **Redis Follower** (2 replicas) — read replicas
- **Frontend** (3 replicas) — PHP app talking to Redis

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Minikube Cluster                   │
│                  ns: guestbook                      │
│                                                     │
│   ┌──────────────┐     ┌──────────────────────┐    │
│   │   Frontend   │────▶│    Redis Leader      │    │
│   │  (3 replicas)│     │    (1 replica)       │    │
│   │  ClusterIP   │     │    ClusterIP :6379   │    │
│   │  port: 80    │     └──────────────────────┘    │
│   └──────┬───────┘              ▲                  │
│          │              ┌───────┴──────────┐        │
│          │              │  Redis Follower  │        │
│          │              │  (2 replicas)    │        │
│          │              │  ClusterIP :6379 │        │
│          │              └──────────────────┘        │
└──────────┼──────────────────────────────────────────┘
           │  kubectl port-forward
           ▼
     localhost:8080
```

---

## 🛠️ Tools & Stack

| Tool | Purpose |
|------|---------|
| **VS Code** | IDE |
| **Cline** (cline.bot) | AI agent extension — proposes and executes commands with approval |
| **OpenRouter** | API gateway to access free LLM models for Cline's reasoning |
| **stepfun/step-3.5-flash** | Free LLM model used via OpenRouter |
| **Minikube** | Local single-node Kubernetes cluster (`--driver=docker`) |
| **kubectl** | Kubernetes CLI |
| **Docker Desktop** | Container runtime (Linux containers mode) |

---

## 📁 Folder Structure

```
k8s-using-ai-agent-on-minikube/
├── README.md
├── git-push.ps1                    # One-shot commit & push script
├── manifests/                      # All Kubernetes YAML files
│   ├── redis-leader-deployment.yaml
│   ├── redis-leader-service.yaml
│   ├── redis-follower-deployment.yaml
│   ├── redis-follower-service.yaml
│   ├── frontend-deployment.yaml
│   └── frontend-service.yaml
├── scripts/
│   ├── deploy.ps1                  # Start minikube + apply all manifests
│   ├── port-forward.ps1            # Forward frontend to localhost:8080
│   └── cleanup.ps1                 # Delete namespace (+ optional minikube stop)
├── screenshots/
│   ├── 01-deployment-status.png    # Pod pending → running debug
│   ├── 02-minikube-service-url.png # Minikube service URL resolution
│   ├── 03-guestbook-app-running.png# App live at localhost:8080
│   └── 04-cline-vscode-final.png   # Cline task completed in VS Code
└── docs/
    └── AI_Agent_Assisted_Kubernetes_Deployment.docx  # Full workflow document
```

---

## 🚀 How to Reproduce

### Prerequisites (once per machine)

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — Linux containers mode
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) — `winget install Kubernetes.minikube`
- [kubectl](https://kubernetes.io/docs/tasks/tools/) — `winget install Kubernetes.kubectl`
- [VS Code](https://code.visualstudio.com/) + [Cline extension](https://marketplace.visualstudio.com/items?itemName=cline.bot)
- [OpenRouter account](https://openrouter.ai/) + API key (free tier works)

### Option A — Use the PowerShell scripts (recommended)

```powershell
# 1. Clone the repo
git clone https://github.com/NinadD26/k8s-using-ai-agent-on-minikube.git
cd k8s-using-ai-agent-on-minikube

# 2. Deploy everything
.\scripts\deploy.ps1

# 3. In a NEW terminal — port-forward and access the app
.\scripts\port-forward.ps1
# Open http://localhost:8080 in your browser

# 4. When done — cleanup
.\scripts\cleanup.ps1
# Or to also stop Minikube:
.\scripts\cleanup.ps1 -StopMinikube
```

### Option B — Manual kubectl commands

```powershell
# Start Minikube
minikube start --driver=docker

# Create namespace
kubectl create namespace guestbook

# Apply manifests in order
kubectl apply -f manifests/redis-leader-deployment.yaml -n guestbook
kubectl apply -f manifests/redis-leader-service.yaml -n guestbook
kubectl apply -f manifests/redis-follower-deployment.yaml -n guestbook
kubectl apply -f manifests/redis-follower-service.yaml -n guestbook
kubectl apply -f manifests/frontend-deployment.yaml -n guestbook
kubectl apply -f manifests/frontend-service.yaml -n guestbook

# Wait for pods
kubectl wait --for=condition=ready pod --all -n guestbook --timeout=120s

# Check status
kubectl get pods -n guestbook

# Port-forward (keep terminal open)
kubectl port-forward svc/frontend 8080:80 -n guestbook
```

---

## 🤖 How Cline Was Used (AI Workflow)

Cline was given short **micro-step prompts** like:

```
"Deploy the official Kubernetes Guestbook app to Minikube in a namespace called guestbook.
Use the manifests from https://k8s.io/examples/application/guestbook/
Apply them one by one and verify pods are running before port-forwarding."
```

Cline then:
1. Fetched manifests from the official k8s.io URLs
2. Applied each manifest with `kubectl apply`
3. Checked pod status and waited for readiness
4. Debugged a `pod not running` error (image pull delay) autonomously
5. Set up port-forwarding once all pods were `Running`

Every command required **explicit human approval** before execution — no blind auto-run.

---

## 🐛 Issues Encountered & Fixes

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| `error: unable to forward port because pod is not running` | Image pull still in progress (status: Pending) | Cline waited, re-checked pods, retried port-forward once Running |
| `SVC_NOT_FOUND: Service 'frontend' was not found in 'default' namespace` | minikube service command missing `-n guestbook` | Cline self-corrected and added `-n guestbook` flag |

---

## 📚 References

- [Kubernetes Guestbook Tutorial](https://kubernetes.io/docs/tutorials/stateless-application/guestbook/)
- [Cline Documentation](https://docs.cline.bot)
- [OpenRouter Free Models](https://openrouter.ai/models?q=free)
- [Minikube Getting Started](https://minikube.sigs.k8s.io/docs/start/)

---

## 👤 Author

**Ninad Divekar** — DevOps Lead | AWS Solutions Architect Associate | Terraform Associate  
[GitHub](https://github.com/NinadD26) · [LinkedIn](https://www.linkedin.com/in/ninad-divekar)
