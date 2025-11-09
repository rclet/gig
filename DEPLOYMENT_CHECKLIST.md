# 📋 Deployment Checklist for fix.com.bd

Quick reference checklist for deploying to Namecheap shared hosting.

---

## Pre-Deployment

- [ ] Repository up-to-date
- [ ] All tests passing
- [ ] Domain active (fix.com.bd)
- [ ] cPanel access available
- [ ] FTP credentials ready

---

## Build Package

- [ ] Run `./deploy_to_namecheap.sh`
- [ ] Verify `deploy_package/` created
- [ ] Check .htaccess files present
- [ ] Review upload instructions

---

## Database Setup

- [ ] Log in to cPanel
- [ ] Create MySQL database
- [ ] Create database user
- [ ] Grant ALL PRIVILEGES
- [ ] Document credentials:
  ```
  DB_DATABASE: _______________
  DB_USERNAME: _______________
  DB_PASSWORD: _______________
  ```

---

## File Upload

- [ ] Connect via FTP to server
- [ ] Navigate to `/public_html`
- [ ] Upload ALL files from `deploy_package/`
- [ ] Verify upload completed
- [ ] Check file count matches

---

## Configuration

- [ ] Rename `.env.production` to `.env`
- [ ] Edit `.env` with database credentials
- [ ] Set `APP_URL=https://fix.com.bd`
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`

---

## Permissions

- [ ] `storage/` → 755
- [ ] `bootstrap/cache/` → 755
- [ ] `.env` → 644

---

## Initialize Application

```bash
cd /home/username/public_html
```

- [ ] `php artisan key:generate`
- [ ] `php artisan migrate --force`
- [ ] `php artisan storage:link`
- [ ] `php artisan optimize`

---

## SSL Certificate

- [ ] cPanel → SSL/TLS Status
- [ ] Run AutoSSL for fix.com.bd
- [ ] Verify HTTPS works
- [ ] Test HTTP→HTTPS redirect

---

## Cron Jobs

- [ ] cPanel → Cron Jobs
- [ ] Add Laravel scheduler:
  ```
  * * * * * cd /home/username/public_html && php artisan schedule:run
  ```

---

## Testing

- [ ] Visit https://fix.com.bd
- [ ] Test user registration
- [ ] Test user login
- [ ] Check API endpoints
- [ ] Test file uploads
- [ ] Verify email sending

---

## Monitoring

- [ ] Upload `diagnose_server.sh`
- [ ] Run diagnostics
- [ ] Check error logs
- [ ] Configure backups

---

## Post-Deployment

- [ ] Monitor error logs (first 24 hours)
- [ ] Set up automated backups
- [ ] Document custom configurations
- [ ] Team notified

---

## Emergency Contacts

**Hosting**: Namecheap Support - https://support.namecheap.com  
**Developer**: _________________  
**DevOps**: _________________

---

**Deployment Date**: _______________  
**Deployed By**: _______________  
**Status**: ⬜ Preparing ⬜ In Progress ⬜ Testing ⬜ Live

---

For detailed instructions, see [NAMECHEAP_DEPLOYMENT.md](NAMECHEAP_DEPLOYMENT.md)
