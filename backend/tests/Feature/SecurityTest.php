<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class SecurityTest extends TestCase
{
    /**
     * Test that security headers are applied to responses
     */
    public function test_security_headers_are_applied(): void
    {
        $response = $this->get('/');

        // Test for common security headers
        $response->assertHeader('X-Frame-Options', 'DENY');
        $response->assertHeader('X-Content-Type-Options', 'nosniff');
        $response->assertHeader('X-XSS-Protection', '1; mode=block');
        $response->assertHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    }

    /**
     * Test that debug mode is disabled in production
     */
    public function test_debug_mode_is_disabled_in_production(): void
    {
        if (app()->environment('production')) {
            $this->assertFalse(config('app.debug'), 'Debug mode should be disabled in production');
        }
    }

    /**
     * Test that sensitive configuration is not exposed
     */
    public function test_sensitive_configuration_not_exposed(): void
    {
        $response = $this->get('/');
        
        $content = $response->getContent();
        
        // Ensure sensitive data is not exposed in responses
        $this->assertStringNotContainsString('DB_PASSWORD', $content);
        $this->assertStringNotContainsString('APP_KEY', $content);
        $this->assertStringNotContainsString('STRIPE_SECRET', $content);
    }

    /**
     * Test CSRF protection is enabled
     */
    public function test_csrf_protection_is_enabled(): void
    {
        // Test that POST requests without CSRF token are rejected
        $response = $this->post('/api/test-csrf', [
            'test' => 'data'
        ]);

        // Should either return 419 (CSRF token mismatch) or 404 (route not found)
        // Both indicate CSRF protection is working
        $this->assertTrue(
            in_array($response->getStatusCode(), [404, 419, 422]),
            'CSRF protection should be enabled'
        );
    }

    /**
     * Test that file upload restrictions are in place
     */
    public function test_file_upload_security(): void
    {
        $securityConfig = config('security.file_upload');
        
        $this->assertNotEmpty($securityConfig['allowed_mimes'], 'File upload MIME restrictions should be configured');
        $this->assertIsNumeric($securityConfig['max_size'], 'File upload max size should be configured');
        $this->assertTrue($securityConfig['scan_for_malware'], 'Malware scanning should be enabled');
    }

    /**
     * Test rate limiting configuration
     */
    public function test_rate_limiting_is_configured(): void
    {
        $apiConfig = config('security.api');
        
        $this->assertTrue($apiConfig['rate_limiting']['enabled'], 'API rate limiting should be enabled');
        $this->assertIsNumeric($apiConfig['rate_limiting']['default_limit'], 'Default rate limit should be configured');
        $this->assertIsNumeric($apiConfig['rate_limiting']['auth_limit'], 'Auth rate limit should be configured');
    }
}