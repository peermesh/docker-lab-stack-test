#!/bin/bash
# Generate secrets for Core Stack Test
# Creates all required secret files for services

set -e

SECRETS_DIR="$(dirname "$0")/../secrets"

echo "=== Core Stack Test - Secret Generation ==="
echo ""

# Create secrets directory
mkdir -p "$SECRETS_DIR"

# Helper function to generate secrets
generate_secret() {
    local name="$1"
    local length="${2:-32}"
    local file="$SECRETS_DIR/$name"

    if [ -f "$file" ] && [ -s "$file" ]; then
        echo "✓ $name (exists)"
    else
        openssl rand -hex "$length" > "$file"
        chmod 600 "$file"
        echo "✓ $name (generated)"
    fi
}

generate_password() {
    local name="$1"
    local length="${2:-24}"
    local file="$SECRETS_DIR/$name"

    if [ -f "$file" ] && [ -s "$file" ]; then
        echo "✓ $name (exists)"
    else
        # Generate password with alphanumeric + some special chars
        openssl rand -base64 "$length" | tr -d '\n/+=' | head -c "$length" > "$file"
        chmod 600 "$file"
        echo "✓ $name (generated)"
    fi
}

generate_app_key() {
    local name="$1"
    local file="$SECRETS_DIR/$name"

    if [ -f "$file" ] && [ -s "$file" ]; then
        echo "✓ $name (exists)"
    else
        # Laravel-style base64 app key
        echo "base64:$(openssl rand -base64 32)" > "$file"
        chmod 600 "$file"
        echo "✓ $name (generated)"
    fi
}

echo "Database Passwords:"
generate_password "mysql_root_password"
generate_password "postgres_password"
generate_password "mongodb_password"
generate_password "minio_password"

echo ""
echo "Application Secrets:"
generate_password "listmonk_db_password"
generate_secret "n8n_encryption_key" 32
generate_password "fuseki_password"
generate_secret "activitypods_cookie_secret" 32
generate_app_key "pixelfed_app_key"
generate_secret "castopod_analytics_salt" 32
generate_secret "manyfold_secret_key" 64
generate_secret "peertube_secret" 32

echo ""
echo "=== Secret generation complete ==="
echo ""
echo "Files created in: $SECRETS_DIR"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env"
echo "  2. Edit .env with your domain and settings"
echo "  3. Run: docker compose --profile <pattern> up -d"
echo ""

# Create .gitkeep to ensure secrets dir is in git
touch "$SECRETS_DIR/.gitkeep"

# Create .gitignore to exclude actual secrets
cat > "$SECRETS_DIR/.gitignore" << 'EOF'
# Ignore all secrets except gitkeep
*
!.gitkeep
!.gitignore
EOF

echo "Done!"
