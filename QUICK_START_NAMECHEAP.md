# 🚀 Quick Start: Deploy to Namecheap (fix.com.bd)

Get your Gig Marketplace deployed to Namecheap shared hosting in under 30 minutes.

---

## ⚡ 5-Step Quick Deploy

### Step 1: Prepare Package (Local - 2 min)
```bash
cd /path/to/gig
./deploy_to_namecheap.sh
```
✅ Creates `deploy_package` folder ready to upload

### Step 2: Database Setup (cPanel - 3 min)
1. Log in to cPanel: `https://cpanel.namecheap.com`
2. **MySQL® Databases** → Create:
   - Database: `username_gig_marketplace`
   - User with strong password
   - Grant ALL PRIVILEGES
3. **Save credentials!**

### Step 3: Upload Files (FTP - 15 min)
1. Connect FileZilla to `ftp.fix.com.bd`
2. Navigate to `/public_html`
3. Upload ALL files from `deploy_package/`
4. Wait for completion

### Step 4: Configure (File Manager - 2 min)
1. cPanel → **File Manager** → `public_html`
2. Rename `.env.production` → `.env`
3. Edit `.env`:
   ```env
   DB_DATABASE=your_database_name
   DB_USERNAME=your_db_user
   DB_PASSWORD=your_db_password
   APP_URL=https://fix.com.bd
   ```

### Step 5: Initialize (Terminal - 5 min)
```bash
cd /home/username/public_html
php artisan key:generate
php artisan migrate --force
php artisan storage:link
php artisan optimize
```

### Bonus: SSL (cPanel - 5 min)
1. cPanel → **SSL/TLS Status**
2. Find `fix.com.bd` → **Run AutoSSL**

### Bonus: Cron Job (cPanel - 2 min)
1. cPanel → **Cron Jobs**
2. Add:
   ```
   * * * * * cd /home/username/public_html && php artisan schedule:run
   ```

---

## ✅ Test Your Deployment

Visit: `https://fix.com.bd`

---

## 🆘 Quick Fixes

**500 Error?**
```bash
chmod -R 755 storage bootstrap/cache
```

**Database Error?**
- Check `.env` credentials match cPanel database

**Can't Generate Key?**
```bash
php -v  # Must be 8.2+
```

---

## 📚 Need More Detail?

- **Full Guide**: [NAMECHEAP_DEPLOYMENT.md](NAMECHEAP_DEPLOYMENT.md)
- **Checklist**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
- **Diagnostics**: Upload `diagnose_server.sh` and run it
- **Scripts**: [DEPLOYMENT_SCRIPTS_README.md](DEPLOYMENT_SCRIPTS_README.md)

---

**Total Time**: ~30 minutes (first deployment)  
**Difficulty**: ⭐⭐☆☆☆ Easy
