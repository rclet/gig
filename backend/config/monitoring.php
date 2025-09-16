<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Application Monitoring Configuration
    |--------------------------------------------------------------------------
    |
    | This file contains monitoring and alerting settings for the Gig
    | Marketplace application in production environments.
    |
    */

    /**
     * Performance monitoring
     */
    'performance' => [
        'enabled' => env('MONITORING_ENABLED', true),
        'slow_query_threshold' => env('SLOW_QUERY_THRESHOLD', 1000), // milliseconds
        'slow_request_threshold' => env('SLOW_REQUEST_THRESHOLD', 2000), // milliseconds
        'memory_limit_warning' => env('MEMORY_LIMIT_WARNING', 80), // percentage
        'cpu_usage_warning' => env('CPU_USAGE_WARNING', 80), // percentage
    ],

    /**
     * Error tracking and alerting
     */
    'alerting' => [
        'enabled' => env('ALERTING_ENABLED', true),
        'email_recipients' => explode(',', env('ALERT_EMAIL_RECIPIENTS', '')),
        'slack_webhook' => env('SLACK_WEBHOOK_URL', ''),
        'error_rate_threshold' => env('ERROR_RATE_THRESHOLD', 5), // errors per minute
        'response_time_threshold' => env('RESPONSE_TIME_THRESHOLD', 3000), // milliseconds
    ],

    /**
     * Health check configuration
     */
    'health_checks' => [
        'enabled' => env('HEALTH_CHECKS_ENABLED', true),
        'interval' => env('HEALTH_CHECK_INTERVAL', 60), // seconds
        'timeout' => env('HEALTH_CHECK_TIMEOUT', 10), // seconds
        'critical_services' => [
            'database',
            'redis',
            'storage',
        ],
        'external_services' => [
            'stripe' => env('STRIPE_KEY') ? true : false,
            'openai' => env('OPENAI_API_KEY') ? true : false,
            'firebase' => env('FIREBASE_PROJECT_ID') ? true : false,
        ],
    ],

    /**
     * Metrics collection
     */
    'metrics' => [
        'enabled' => env('METRICS_ENABLED', true),
        'retention_days' => env('METRICS_RETENTION_DAYS', 30),
        'collection_interval' => env('METRICS_COLLECTION_INTERVAL', 300), // seconds
        'track' => [
            'request_count',
            'response_time',
            'error_rate',
            'user_registrations',
            'job_postings',
            'payments_processed',
            'active_users',
        ],
    ],

    /**
     * Log monitoring
     */
    'logs' => [
        'error_patterns' => [
            'CRITICAL',
            'EMERGENCY',
            'Fatal error',
            'Uncaught exception',
            'Database connection failed',
            'Payment failed',
        ],
        'exclude_patterns' => [
            'favicon.ico',
            'robots.txt',
            'sitemap.xml',
        ],
        'max_log_size' => env('MAX_LOG_SIZE', 100), // MB
        'log_rotation_days' => env('LOG_ROTATION_DAYS', 7),
    ],

    /**
     * Security monitoring
     */
    'security' => [
        'monitor_failed_logins' => env('MONITOR_FAILED_LOGINS', true),
        'failed_login_threshold' => env('FAILED_LOGIN_THRESHOLD', 5),
        'failed_login_window' => env('FAILED_LOGIN_WINDOW', 900), // seconds
        'monitor_suspicious_activity' => env('MONITOR_SUSPICIOUS_ACTIVITY', true),
        'ip_whitelist' => explode(',', env('SECURITY_IP_WHITELIST', '')),
        'ip_blacklist' => explode(',', env('SECURITY_IP_BLACKLIST', '')),
    ],

    /**
     * Business metrics monitoring
     */
    'business_metrics' => [
        'track_user_activity' => env('TRACK_USER_ACTIVITY', true),
        'track_revenue' => env('TRACK_REVENUE', true),
        'track_job_completion_rate' => env('TRACK_JOB_COMPLETION_RATE', true),
        'track_user_satisfaction' => env('TRACK_USER_SATISFACTION', true),
        'daily_reports' => env('DAILY_BUSINESS_REPORTS', true),
        'weekly_reports' => env('WEEKLY_BUSINESS_REPORTS', true),
    ],

    /**
     * Notification channels
     */
    'notifications' => [
        'email' => [
            'enabled' => env('EMAIL_NOTIFICATIONS_ENABLED', true),
            'from' => env('NOTIFICATION_FROM_EMAIL', 'alerts@gig.com.bd'),
            'recipients' => explode(',', env('NOTIFICATION_EMAIL_RECIPIENTS', '')),
        ],
        'slack' => [
            'enabled' => env('SLACK_NOTIFICATIONS_ENABLED', false),
            'webhook_url' => env('SLACK_WEBHOOK_URL', ''),
            'channel' => env('SLACK_CHANNEL', '#alerts'),
        ],
        'sms' => [
            'enabled' => env('SMS_NOTIFICATIONS_ENABLED', false),
            'provider' => env('SMS_PROVIDER', 'twilio'),
            'emergency_numbers' => explode(',', env('EMERGENCY_SMS_NUMBERS', '')),
        ],
    ],

    /**
     * Incident response
     */
    'incident_response' => [
        'auto_scaling' => env('AUTO_SCALING_ENABLED', false),
        'circuit_breaker' => env('CIRCUIT_BREAKER_ENABLED', true),
        'fallback_mode' => env('FALLBACK_MODE_ENABLED', true),
        'maintenance_mode_threshold' => env('MAINTENANCE_MODE_THRESHOLD', 95), // error rate percentage
    ],
];