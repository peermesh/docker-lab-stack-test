# WriteFreely - Minimalist Blogging Pattern

Lightweight, distraction-free blogging with native ActivityPub federation.

## Why WriteFreely?

- **128MB RAM** vs 1GB+ for Ghost
- Native ActivityPub (followers from Mastodon)
- Markdown-first writing
- Single or multi-user modes

## Quick Start

```bash
# 1. Copy and configure environment
cp .env.example .env
# Edit .env with your domain settings

# 2. Create MySQL database (if using MySQL profile)
docker compose exec mysql mysql -u root -p -e "CREATE DATABASE writefreely;"
docker compose exec mysql mysql -u root -p -e "CREATE USER 'writefreely'@'%' IDENTIFIED BY 'your_secure_password';"
docker compose exec mysql mysql -u root -p -e "GRANT ALL ON writefreely.* TO 'writefreely'@'%';"

# 3. Start WriteFreely
docker compose -f docker-compose.yml \
               -f patterns/writefreely/docker-compose.writefreely.yml \
               --profile mysql --profile writefreely up -d
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `example.com` | Your base domain |
| `WRITEFREELY_SITE_NAME` | `My Blog` | Display name for the blog |
| `WRITEFREELY_SINGLE_USER` | `false` | Single-user mode toggle |

### Access

- **URL**: `https://blog.${DOMAIN}`
- **ActivityPub**: `@username@blog.${DOMAIN}`

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| RAM | 64-256MB |
| CPU | 0.1 cores |
| Disk | ~10MB + posts |

## Features

- Clean, minimal writing interface
- ActivityPub federation
- Custom CSS per blog
- Anonymous posting option
- RSS feeds

## Files

```
patterns/writefreely/
├── README.md                         # This file
├── docker-compose.writefreely.yml    # Docker Compose fragment
├── config/
│   └── config.ini.template           # WriteFreely configuration template
└── PATTERN-SETUP.md                  # Pattern setup summary
```

## License

Apache 2.0 - See repository LICENSE file.
