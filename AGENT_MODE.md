# Running Gig Marketplace in Agent Mode

This guide explains how to run the Gig Marketplace application in "agent mode", which refers to running the Laravel backend services as persistent background agents/daemons.

## What is Agent Mode?

Agent mode consists of two main components:

1. **Laravel Horizon** - Queue worker supervisor that processes background jobs
2. **Laravel Application Server** - The API server that handles HTTP requests

Both services run as persistent agents in the background, making them suitable for production deployment.

## Prerequisites

Before running in agent mode, ensure you have:

- PHP 8.2+ installed
- Composer installed
- Redis server running (required for Horizon)
- Database server (MySQL recommended, SQLite for development)

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
composer install
```

### 2. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure your database and Redis settings in .env
# For SQLite (development):
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite

# For MySQL (production):
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=gig_marketplace
DB_USERNAME=root
DB_PASSWORD=your_password

# Redis configuration (required for Horizon)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
QUEUE_CONNECTION=redis
```

### 3. Setup Database

```bash
# Create database file (SQLite only)
touch database/database.sqlite

# Run migrations
php artisan migrate --force

# Seed database (optional)
php artisan db:seed --force
```

### 4. Install Agent Services

```bash
# Install Horizon (queue worker agent)
php artisan horizon:install

# Install Octane (optional, for high-performance server)
php artisan octane:install
```

## Running in Agent Mode

### Start Redis Server

Redis must be running before starting Horizon:

```bash
# On Ubuntu/Debian
sudo service redis-server start

# On macOS with Homebrew
brew services start redis

# Verify Redis is running
redis-cli ping
# Should return: PONG
```

### Start Laravel Horizon (Queue Worker Agent)

Horizon runs as a supervisor that manages queue workers:

```bash
# Start Horizon in the foreground (for testing)
php artisan horizon

# In production, run Horizon as a background service using systemd or supervisor
```

Check Horizon status:

```bash
php artisan horizon:status
php artisan horizon:supervisors
```

Access Horizon dashboard at: `http://your-domain.com/horizon`

### Start Laravel Application Server

For development:

```bash
# Standard Laravel development server
php artisan serve --host=0.0.0.0 --port=8000
```

For production with Octane (requires Swoole or RoadRunner):

```bash
# Install Swoole PHP extension
pecl install swoole

# Start Octane server
php artisan octane:start --host=0.0.0.0 --port=8000 --workers=4
```

## Running as System Services (Production)

### Horizon Service (systemd)

Create `/etc/systemd/system/gig-horizon.service`:

```ini
[Unit]
Description=Gig Marketplace Horizon
After=network.target redis.service mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/gig-marketplace/backend
ExecStart=/usr/bin/php artisan horizon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable gig-horizon
sudo systemctl start gig-horizon
sudo systemctl status gig-horizon
```

### Application Server Service (systemd with Octane)

Create `/etc/systemd/system/gig-octane.service`:

```ini
[Unit]
Description=Gig Marketplace Octane Server
After=network.target redis.service mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/gig-marketplace/backend
ExecStart=/usr/bin/php artisan octane:start --server=swoole --host=127.0.0.1 --port=8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable gig-octane
sudo systemctl start gig-octane
sudo systemctl status gig-octane
```

## Monitoring Agent Mode

### Check Horizon Status

```bash
# Check if Horizon is running
php artisan horizon:status

# View all supervisors
php artisan horizon:supervisors

# View supervisor status
php artisan horizon:supervisor-status supervisor-1
```

### Check Application Server

```bash
# For Octane
php artisan octane:status

# Test API endpoint
curl http://localhost:8000/api/auth/login
```

### View Logs

```bash
# Application logs
tail -f storage/logs/laravel.log

# Horizon logs (systemd)
sudo journalctl -u gig-horizon -f

# Octane logs (systemd)
sudo journalctl -u gig-octane -f
```

## Stopping Agent Mode

### Stop Horizon

```bash
# Graceful termination
php artisan horizon:terminate

# Or force stop
php artisan horizon:purge

# For systemd service
sudo systemctl stop gig-horizon
```

### Stop Application Server

```bash
# For Octane
php artisan octane:stop

# For systemd service
sudo systemctl stop gig-octane

# For development server, press Ctrl+C
```

## Troubleshooting

### Horizon Not Starting

1. Check Redis is running: `redis-cli ping`
2. Check queue configuration in `.env`: `QUEUE_CONNECTION=redis`
3. Clear config cache: `php artisan config:clear`
4. Check permissions: `chmod -R 775 storage bootstrap/cache`

### Application Server Errors

1. Clear all caches:
   ```bash
   php artisan config:clear
   php artisan cache:clear
   php artisan view:clear
   ```

2. Check storage permissions:
   ```bash
   chmod -R 775 storage bootstrap/cache
   ```

3. Verify database connection:
   ```bash
   php artisan migrate:status
   ```

### Database Migration Issues

If using SQLite, ensure fulltext indexes are disabled:
- The migration has been updated to conditionally create fulltext indexes only for MySQL

For MySQL setup issues:
```bash
# Test MySQL connection
mysql -u root -p -e "SELECT 1"

# Create database manually
mysql -u root -p -e "CREATE DATABASE gig_marketplace"
```

## Performance Tips

1. **Enable OPcache** in production:
   ```ini
   opcache.enable=1
   opcache.memory_consumption=256
   opcache.max_accelerated_files=20000
   ```

2. **Use Redis for sessions and cache**:
   ```env
   SESSION_DRIVER=redis
   CACHE_STORE=redis
   ```

3. **Optimize Laravel**:
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

4. **Configure Horizon workers** in `config/horizon.php`:
   ```php
   'production' => [
       'supervisor-1' => [
           'maxProcesses' => 10,
           'balanceMaxShift' => 1,
           'balanceCooldown' => 3,
       ],
   ],
   ```

## Additional Resources

- [Laravel Horizon Documentation](https://laravel.com/docs/horizon)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [Queue Workers Documentation](https://laravel.com/docs/queues)

## Summary

The application is now running in agent mode with:
- ✅ Horizon supervising queue workers
- ✅ Application server handling HTTP requests
- ✅ Redis managing queues and cache
- ✅ Database properly configured

Both services can run as systemd services for production deployments.
