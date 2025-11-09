#!/bin/bash

#################################################################################
# Namecheap Backup Script for Gig Marketplace
# Domain: fix.com.bd
#
# This script should be uploaded to your server and run via cron or manually
# to create regular backups of your application and database.
#################################################################################

# Configuration - Update these paths for your server
APP_PATH="/home/username/public_html"
BACKUP_PATH="/home/username/backups"
DB_NAME="your_database_name"
DB_USER="your_database_user"
DB_PASS="your_database_password"

# Backup retention (days)
RETENTION_DAYS=30

# Date format for backup files
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_PATH/backup_$DATE"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting backup process...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
echo "Backing up database..."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/database.sql"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database backup completed${NC}"
else
    echo -e "${YELLOW}⚠️  Database backup failed${NC}"
fi

# Backup application files
echo "Backing up application files..."
tar -czf "$BACKUP_DIR/files.tar.gz" \
    --exclude='vendor' \
    --exclude='node_modules' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    -C "$APP_PATH" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Files backup completed${NC}"
else
    echo -e "${YELLOW}⚠️  Files backup failed${NC}"
fi

# Backup .env file separately (encrypted)
echo "Backing up environment configuration..."
cp "$APP_PATH/.env" "$BACKUP_DIR/.env.backup"

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup Date: $(date)
Database: $DB_NAME
Application Path: $APP_PATH
Backup Size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF

echo -e "${GREEN}✅ Backup completed: $BACKUP_DIR${NC}"

# Cleanup old backups
echo "Cleaning up old backups (older than $RETENTION_DAYS days)..."
find "$BACKUP_PATH" -name "backup_*" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null
echo -e "${GREEN}✅ Cleanup completed${NC}"

# Create compressed archive
cd "$BACKUP_PATH"
tar -czf "backup_${DATE}.tar.gz" "backup_$DATE"
rm -rf "backup_$DATE"

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Backup completed successfully! ✅${NC}"
echo -e "${GREEN}  Archive: backup_${DATE}.tar.gz${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
