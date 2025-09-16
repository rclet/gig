<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Security Configuration
    |--------------------------------------------------------------------------
    |
    | This file contains security settings for the Gig Marketplace application.
    | These settings help protect against common security vulnerabilities.
    |
    */

    /**
     * Content Security Policy (CSP) configuration
     */
    'csp' => [
        'enabled' => env('CSP_ENABLED', true),
        'report_only' => env('CSP_REPORT_ONLY', false),
        'directives' => [
            'default-src' => "'self'",
            'script-src' => "'self' 'unsafe-inline' 'unsafe-eval' https://www.google.com https://www.gstatic.com https://apis.google.com https://connect.facebook.net",
            'style-src' => "'self' 'unsafe-inline' https://fonts.googleapis.com",
            'img-src' => "'self' data: https: blob:",
            'font-src' => "'self' https://fonts.gstatic.com",
            'connect-src' => "'self' https://api.gig.com.bd wss://api.gig.com.bd https://www.google-analytics.com",
            'media-src' => "'self' blob:",
            'object-src' => "'none'",
            'frame-src' => "'self' https://www.google.com https://www.facebook.com",
            'form-action' => "'self'",
            'base-uri' => "'self'",
        ],
    ],

    /**
     * HTTP Security Headers
     */
    'headers' => [
        'x_frame_options' => 'DENY',
        'x_content_type_options' => 'nosniff',
        'x_xss_protection' => '1; mode=block',
        'referrer_policy' => 'strict-origin-when-cross-origin',
        'permissions_policy' => 'geolocation=(), microphone=(), camera=()',
        'strict_transport_security' => [
            'enabled' => env('HSTS_ENABLED', true),
            'max_age' => 31536000,
            'include_subdomains' => true,
            'preload' => true,
        ],
    ],

    /**
     * File Upload Security
     */
    'file_upload' => [
        'max_size' => env('FILE_UPLOAD_MAX_SIZE', 10240), // KB
        'allowed_mimes' => [
            'images' => ['jpg', 'jpeg', 'png', 'gif', 'webp'],
            'documents' => ['pdf', 'doc', 'docx', 'txt'],
            'archives' => ['zip', 'rar'],
        ],
        'scan_for_malware' => env('FILE_SCAN_MALWARE', true),
        'quarantine_path' => storage_path('app/quarantine'),
    ],

    /**
     * API Security
     */
    'api' => [
        'rate_limiting' => [
            'enabled' => env('API_RATE_LIMITING_ENABLED', true),
            'default_limit' => env('API_RATE_LIMIT', 60),
            'auth_limit' => env('AUTH_RATE_LIMIT', 5),
            'guest_limit' => env('GUEST_RATE_LIMIT', 10),
        ],
        'request_logging' => env('API_REQUEST_LOGGING', true),
        'response_signing' => env('API_RESPONSE_SIGNING', false),
    ],

    /**
     * Session Security
     */
    'session' => [
        'secure_cookies' => env('SESSION_SECURE_COOKIES', true),
        'http_only' => true,
        'same_site' => 'lax',
        'regenerate_on_login' => true,
        'timeout_minutes' => env('SESSION_TIMEOUT', 120),
    ],

    /**
     * Database Security
     */
    'database' => [
        'encrypt_connection' => env('DB_ENCRYPT', true),
        'verify_ssl' => env('DB_SSL_VERIFY', true),
        'log_queries' => env('DB_LOG_QUERIES', false),
        'slow_query_threshold' => env('DB_SLOW_QUERY_THRESHOLD', 1000), // ms
    ],

    /**
     * Audit Logging
     */
    'audit' => [
        'enabled' => env('AUDIT_LOGGING_ENABLED', true),
        'events' => [
            'login',
            'logout', 
            'password_change',
            'email_change',
            'profile_update',
            'payment_processed',
            'job_posted',
            'proposal_submitted',
        ],
        'retention_days' => env('AUDIT_RETENTION_DAYS', 365),
    ],

    /**
     * Security Monitoring
     */
    'monitoring' => [
        'failed_login_threshold' => env('FAILED_LOGIN_THRESHOLD', 5),
        'failed_login_window' => env('FAILED_LOGIN_WINDOW', 900), // seconds
        'suspicious_activity_detection' => env('SUSPICIOUS_ACTIVITY_DETECTION', true),
        'ip_whitelist' => explode(',', env('SECURITY_IP_WHITELIST', '')),
        'ip_blacklist' => explode(',', env('SECURITY_IP_BLACKLIST', '')),
    ],

    /**
     * Data Protection
     */
    'data_protection' => [
        'encryption_key_rotation' => env('ENCRYPTION_KEY_ROTATION_DAYS', 90),
        'pii_encryption' => env('PII_ENCRYPTION_ENABLED', true),
        'data_anonymization' => env('DATA_ANONYMIZATION_ENABLED', true),
        'gdpr_compliance' => env('GDPR_COMPLIANCE_ENABLED', true),
    ],
];