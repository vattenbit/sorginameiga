# Deployment runbook

Target: **Google Cloud Run** (container) + **Neon** (Postgres) + **GCS bucket**
for images. All in an EU region.

Set these once for the commands below:

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="europe-west3"          # Frankfurt (near Neon eu-central-1)
export BUCKET="gs://sorginameiga-images"   # must be globally unique
gcloud config set project "$PROJECT_ID"
```

---

> **Status:** Project `sorgina-meiga` (nº 681872954393), billing on. Bucket
> `gs://sorginameiga-images` created in `europe-west3` and seeded (91 objects).

## 8c — Images bucket (GCS) ✅ DONE

The app reads and writes entity photos on the local filesystem under
`Public/images`. On Cloud Run that path is backed by a **GCS bucket mounted as a
volume**, so uploads persist and are shared across instances. No app code
changes — the mount is configured on the Cloud Run service (step 8e).

The bucket stays **private**: the app reads it through the mount and serves the
bytes itself; browsers never access GCS directly.

```bash
# 1. Enable the APIs (also needed later)
gcloud services enable run.googleapis.com \
    artifactregistry.googleapis.com \
    storage.googleapis.com \
    secretmanager.googleapis.com

# 2. Create the bucket (EU, uniform access, private)
gcloud storage buckets create "$BUCKET" \
    --location="$REGION" \
    --uniform-bucket-level-access

# 3. Seed the bucket with the current images (chrome + dog/gallery photos)
deploy/upload-images.sh "$BUCKET"
```

The Cloud Run service account gets read/write on the bucket in step 8e (so
admin photo uploads work).

---

## 8d — Build the image → Artifact Registry ✅ DONE (manual, via Cloud Build)

Repo: `europe-west3-docker.pkg.dev/sorgina-meiga/sorginameiga`. Built in the
cloud (native amd64) rather than cross-compiling on the ARM Mac:

```bash
gcloud artifacts repositories create sorginameiga \
    --repository-format=docker --location="$REGION"

gcloud builds submit --region="$REGION" \
    --tag="$REGION-docker.pkg.dev/$PROJECT_ID/sorginameiga/web:latest" \
    --timeout=2400s --machine-type=e2-highcpu-8
```

(A GitHub Actions pipeline can replace this later — see step 8g/optional.)

## 8e — Deploy to Cloud Run

The Neon connection string lives in Secret Manager as `database-url`. The images
bucket is mounted at `/app/Public/images`. Migrations were already applied to
Neon (8b), so the container only needs to `serve`.

```bash
IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/sorginameiga/web:latest"
SA="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')-compute@developer.gserviceaccount.com"

# The Cloud Run service account needs to read the secret and read/write the bucket.
gcloud secrets add-iam-policy-binding database-url \
    --member="serviceAccount:$SA" --role="roles/secretmanager.secretAccessor"
gcloud storage buckets add-iam-policy-binding "$BUCKET" \
    --member="serviceAccount:$SA" --role="roles/storage.objectAdmin"

gcloud run deploy sorginameiga \
    --image="$IMAGE" \
    --region="$REGION" \
    --allow-unauthenticated \
    --port=8080 \
    --set-secrets=DATABASE_URL=database-url:latest \
    --add-volume=name=images,type=cloud-storage,bucket=sorginameiga-images \
    --add-volume-mount=volume=images,mount-path=/app/Public/images \
    --min-instances=0 --max-instances=4 \
    --cpu=1 --memory=512Mi --concurrency=80
```

Then open the service URL that `gcloud run deploy` prints and verify.

## 8f — Domain, DNS cutover & go-live
_(to be filled in — includes: re-extract the legacy seed fresh, map
sorginameiga.com, switch DNS off the DigitalOcean droplet, verify, rollback
window)_
