# rss2bsky - RSS to Bluesky Syndication

Lightweight cron-based RSS to Bluesky cross-posting. Syndicates Mastodon, WriteFreely, or any RSS feed to Bluesky automatically.

## Features

- **Minimal footprint**: ~20MB RAM during execution, ~2-5MB idle
- **Works with any RSS feed**: Mastodon, WriteFreely, or custom sources
- **Cron-based scheduling**: Configurable sync frequency
- **State persistence**: Tracks posted items to avoid duplicates

## Quick Start

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Configure your `.env` file with:
   - Your Bluesky handle and app password
   - Your RSS feed URL

3. Start the container:
   ```bash
   docker compose up -d
   ```

## Prerequisites

### RSS Feed Source

| Platform | RSS Feed URL Pattern |
|----------|---------------------|
| Mastodon | `https://mastodon.example.com/@username.rss` |
| WriteFreely | `https://blog.example.com/feed/` |
| WriteFreely (single blog) | `https://blog.example.com/username/feed/` |

### Bluesky App Password

1. Log into [bsky.app](https://bsky.app)
2. Go to Settings > App Passwords
3. Create a new app password (name it "rss2bsky")
4. Save the generated password securely

## Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `RSS2BSKY_HANDLE` | Yes | Your Bluesky handle (e.g., `user.bsky.social`) |
| `RSS2BSKY_APP_PASSWORD` | Yes | Bluesky app password (NOT your account password) |
| `RSS2BSKY_FEED_URL` | Yes | Full URL to RSS feed |
| `RSS2BSKY_START_DATE` | No | Only post items after this date (RFC format) |
| `RSS2BSKY_CRON` | No | Cron schedule (default: `*/15 * * * *`) |
| `TZ` | No | Timezone (default: UTC) |

### Cron Schedule Examples

```bash
# Every 15 minutes (default)
RSS2BSKY_CRON="*/15 * * * *"

# Every hour
RSS2BSKY_CRON="0 * * * *"

# Every 6 hours
RSS2BSKY_CRON="0 */6 * * *"

# Once daily at midnight
RSS2BSKY_CRON="0 0 * * *"
```

## Resource Requirements

| State | RAM Usage |
|-------|-----------|
| Idle (crond) | 2-5MB |
| Active (syncing) | ~20MB |
| Peak (large feed) | ~30MB |

## How It Works

1. **On startup**: Runs initial sync immediately
2. **On schedule**: Checks RSS feed for new items
3. **For each new item**: Posts to Bluesky with link back to original
4. **State tracking**: Remembers posted items to avoid duplicates

## Commands

```bash
# Start the container
docker compose up -d

# View logs
docker logs -f rss2bsky

# Trigger manual sync
docker exec rss2bsky /app/sync.sh

# Stop the container
docker compose down
```

## Troubleshooting

### Common Issues

1. **"Authentication failed"**: Verify app password is correct and not expired
2. **"Feed not found"**: Check RSS feed URL is publicly accessible
3. **"No new posts"**: Feed items may be older than `RSS2BSKY_START_DATE`

### Debug Commands

```bash
# Check if container is running
docker ps | grep rss2bsky

# View recent logs
docker logs --tail 50 rss2bsky

# Manual sync test
docker exec rss2bsky /app/sync.sh
```

## Security Notes

- Use **app passwords**, never your account password
- App passwords can be revoked anytime from Bluesky settings
- The container only needs outbound HTTPS access

## Architecture

```
+---------------+     +----------------+     +-------------+
| RSS Feed      |     | rss2bsky       |     | Bluesky     |
| (any source)  | --> | (Alpine+Cron)  | --> | (ATProto)   |
+---------------+     +----------------+     +-------------+
                            |
                      [State File]
                      (tracks posted)
```

## License

MIT
