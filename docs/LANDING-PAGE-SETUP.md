# Landing Page Setup

Documentation for the PeerMesh Docker Lab landing page at `https://dockerlab.peermesh.org/`.

## Overview

A static landing page that provides an index of all installed and planned services in the Docker Lab infrastructure.

## Files Created

### 1. `index/index.html`

The main landing page with:
- PeerMesh branding and logo
- Service cards organized by status (Deployed, Ready, Planned)
- Links to deployed service subdomains
- Responsive, dark-mode friendly design

**Deployed Services:**
- GoToSocial - `social.dockerlab.peermesh.org`
- WriteFreely - `blog.dockerlab.peermesh.org`
- PeerTube - `video.dockerlab.peermesh.org`
- Listmonk - `newsletter.dockerlab.peermesh.org`

**Ready to Deploy:**
- rss2bsky
- n8n

**Planned Services:**
- ActivityPods
- Pixelfed
- Castopod
- Manyfold

### 2. `index/styles.css`

Minimal, professional CSS with:
- CSS custom properties for theming
- Automatic dark/light mode via `prefers-color-scheme`
- Responsive grid layout
- Status badge styling (deployed/ready/planned)
- Hover effects for deployed service cards

### 3. `docker-compose.index.yml`

Compose fragment to serve the landing page via Traefik:
- Uses `nginx:alpine` image
- Mounts `./index` as read-only volume
- Traefik labels for HTTPS routing
- Security headers middleware
- Health check configuration

## Deployment

### Option 1: Standalone

```bash
docker compose -f docker-compose.index.yml up -d
```

### Option 2: With Main Stack

Include as an additional compose file:

```bash
docker compose -f docker-compose.yml -f docker-compose.index.yml up -d
```

### Prerequisites

- Traefik must be running with external network `traefik`
- Let's Encrypt certificate resolver named `letsencrypt`
- DNS for `dockerlab.peermesh.org` pointing to the server

## Customization

### Adding a New Service

Edit `index/index.html` and add a new service card in the appropriate section:

```html
<a href="https://subdomain.dockerlab.peermesh.org" class="service-card deployed">
    <div class="service-icon">🔮</div>
    <div class="service-info">
        <h3>Service Name</h3>
        <p>Service description</p>
        <span class="service-url">subdomain.dockerlab.peermesh.org</span>
    </div>
    <span class="status-badge deployed">Deployed</span>
</a>
```

### Status Levels

- `deployed` - Live and accessible (links to subdomain)
- `ready` - Configuration complete, pending deployment
- `planned` - On roadmap, not yet configured

### Theming

Colors are defined as CSS custom properties in `:root`. The page automatically adapts to system dark/light mode preferences.

## File Structure

```
docker-lab-stack-test/
├── index/
│   ├── index.html          # Landing page HTML
│   └── styles.css          # Stylesheet
├── docker-compose.index.yml # Compose fragment
└── docs/
    └── LANDING-PAGE-SETUP.md # This documentation
```
