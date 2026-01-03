# PeerTube Pattern Setup

## Prerequisites

1. Foundation infrastructure running (Traefik, PostgreSQL)
2. DNS configured for `peertube.${DOMAIN}`
3. Storage for video content (50GB+ recommended)

## Configuration Steps

### 1. Database Setup

PeerTube needs a PostgreSQL database:

```bash
# The database is auto-created when the profile starts
# Manual creation if needed:
docker compose exec postgres psql -U postgres -c "CREATE DATABASE peertube;"
docker compose exec postgres psql -U postgres -c "CREATE USER peertube WITH PASSWORD 'your_password';"
docker compose exec postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE peertube TO peertube;"
```

### 2. Environment Variables

Add to `.env`:

```bash
# PeerTube configuration
PEERTUBE_VERSION=production-bookworm
PEERTUBE_DB_PASSWORD=your_secure_password
PEERTUBE_SECRET=generate_256bit_secret
```

### 3. Generate Secrets

```bash
# Generate PeerTube secret
openssl rand -hex 32 > secrets/peertube_secret

# Or use the generate-secrets script
./scripts/generate-secrets.sh
```

### 4. Deploy

```bash
# Start PeerTube
docker compose --profile peertube up -d

# Watch logs for startup
docker compose logs -f peertube
```

### 5. First-Run Setup

1. Wait for container to become healthy
2. Create admin user via CLI:
   ```bash
   docker compose exec peertube node dist/scripts/create-user \
     --username admin \
     --email admin@example.com \
     --password your_admin_password \
     --role 0
   ```
3. Access `https://peertube.${DOMAIN}`

## Verification

```bash
# Check health
curl -s https://peertube.${DOMAIN}/api/v1/config | jq .instance.name

# Check federation
curl -s https://peertube.${DOMAIN}/api/v1/server/following

# Check videos API
curl -s https://peertube.${DOMAIN}/api/v1/videos
```

## Resource Monitoring

PeerTube is resource-intensive during transcoding:

```bash
# Monitor container resources
docker stats dlst_peertube

# Check transcoding queue
docker compose exec peertube npm run print-transcode-jobs
```

## Troubleshooting

### Container won't start

```bash
# Check PostgreSQL connectivity
docker compose exec peertube ping postgres

# Verify database exists
docker compose exec postgres psql -U postgres -l
```

### Videos not federating

1. Check ActivityPub endpoint: `/.well-known/webfinger`
2. Verify HTTPS is working
3. Check outbox processing logs

### Transcoding failures

1. Check available memory (needs 2GB+)
2. Verify ffmpeg is working inside container
3. Review transcoding job logs
