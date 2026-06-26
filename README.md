# bonos-service

Microservicio de **bonos y promociones** del casino (FastAPI).
Comparte la base de datos PostgreSQL y el `JWT_SECRET` con `casino-backend`.

- Prefijo de rutas: `/api/bonos` · Docs: `/docs`
- Puerto: **8004**

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/bonos` | Catálogo de bonos activos |
| GET | `/api/bonos/mis-bonos` | Bonos reclamados por el usuario |
| POST | `/api/bonos/{codigo}/reclamar` | Reclama un bono |
| GET | `/livez` | Liveness probe (Kubernetes) |
| GET | `/readyz` | Readiness probe — verifica BD (200/503) |

## Variables de entorno

| Variable | Valor por defecto | Descripción |
|----------|------------------|-------------|
| `DB_HOST` | `localhost` | Host de PostgreSQL |
| `DB_PORT` | `5432` | Puerto de PostgreSQL |
| `DB_USER` | `casino` | Usuario de PostgreSQL |
| `DB_PASSWORD` | `casino` | Contraseña de PostgreSQL |
| `DB_NAME` | `casino_db` | Nombre de la BD |
| `JWT_SECRET` | `cambiame` | Clave para validar JWT del backend |
| `CORS_ORIGIN` | `http://localhost:4200` | Origen permitido para CORS |

## Ejecutar en local

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # ajusta las variables
uvicorn app.main:app --reload --port 8004
```

## Construir imagen Docker

```bash
docker build -t bonos-service:latest .
docker run --rm bonos-service:latest whoami  # debe mostrar: appuser
```

## Desplegar en EKS

```bash
# Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name vidal-casino

# Aplicar manifiestos
kubectl apply -f k8s/

# Verificar
kubectl get pods -l app=bonos-service
kubectl logs deployment/bonos-service
```

## CI/CD

El pipeline se dispara con push a la rama `deploy`:

```
dev → (trabajo diario) → merge a deploy → GitHub Actions → ECR → EKS
```

Pasos del pipeline: build imagen → push a ECR (3 tags: vX.Y.Z, latest, SHA) → kubectl set image en EKS.

## Secrets requeridos en GitHub

`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`, `AWS_ACCOUNT_ID`, `EKS_CLUSTER`

## Troubleshooting

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `ImagePullBackOff` | Credenciales AWS expiradas | Actualizar secrets en GitHub |
| `/readyz` responde 503 | BD no disponible | Verificar pod de postgres |
| `CrashLoopBackOff` | Error en variables de entorno | `kubectl logs deployment/bonos-service` |
