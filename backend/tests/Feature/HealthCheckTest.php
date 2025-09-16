<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class HealthCheckTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test health check endpoint returns successful response
     */
    public function test_health_check_endpoint_returns_success(): void
    {
        $response = $this->get('/api/health');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'timestamp',
                    'application',
                    'database',
                    'cache',
                    'storage',
                ]);
    }

    /**
     * Test simple health check endpoint
     */
    public function test_simple_health_check_endpoint(): void
    {
        $response = $this->get('/api/health/simple');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'timestamp',
                ]);
    }

    /**
     * Test health check returns application information
     */
    public function test_health_check_includes_application_info(): void
    {
        $response = $this->get('/api/health');

        $response->assertStatus(200)
                ->assertJsonPath('application.status', 'healthy')
                ->assertJsonPath('application.details.environment', 'testing');
    }
}