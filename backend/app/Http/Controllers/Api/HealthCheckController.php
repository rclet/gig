<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;
use Exception;

class HealthCheckController extends Controller
{
    /**
     * Perform a comprehensive health check of the application
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        $healthChecks = [
            'status' => 'healthy',
            'timestamp' => now()->toISOString(),
            'application' => $this->checkApplication(),
            'database' => $this->checkDatabase(),
            'cache' => $this->checkCache(),
            'storage' => $this->checkStorage(),
            'external_services' => $this->checkExternalServices(),
        ];

        // Determine overall health status
        $allHealthy = collect($healthChecks)->except(['status', 'timestamp'])
            ->every(function ($check) {
                return is_array($check) ? ($check['status'] ?? false) === 'healthy' : true;
            });

        $healthChecks['status'] = $allHealthy ? 'healthy' : 'unhealthy';
        $httpStatus = $allHealthy ? 200 : 503;

        return response()->json($healthChecks, $httpStatus);
    }

    /**
     * Simple health check endpoint for load balancers
     *
     * @return JsonResponse
     */
    public function simple(): JsonResponse
    {
        try {
            // Basic database connectivity check
            DB::connection()->getPdo();
            
            return response()->json([
                'status' => 'healthy',
                'timestamp' => now()->toISOString(),
            ]);
        } catch (Exception $e) {
            Log::error('Health check failed', ['error' => $e->getMessage()]);
            
            return response()->json([
                'status' => 'unhealthy',
                'timestamp' => now()->toISOString(),
                'error' => 'Database connectivity failed',
            ], 503);
        }
    }

    /**
     * Check application health
     *
     * @return array
     */
    private function checkApplication(): array
    {
        try {
            $checks = [
                'laravel_version' => app()->version(),
                'php_version' => PHP_VERSION,
                'environment' => app()->environment(),
                'debug_mode' => config('app.debug'),
                'timezone' => config('app.timezone'),
                'memory_usage' => round(memory_get_usage(true) / 1024 / 1024, 2) . ' MB',
                'memory_limit' => ini_get('memory_limit'),
            ];

            return [
                'status' => 'healthy',
                'details' => $checks,
            ];
        } catch (Exception $e) {
            return [
                'status' => 'unhealthy',
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check database connectivity and performance
     *
     * @return array
     */
    private function checkDatabase(): array
    {
        try {
            $start = microtime(true);
            
            // Test database connection
            $connection = DB::connection();
            $pdo = $connection->getPdo();
            
            // Test a simple query
            $result = DB::select('SELECT 1 as test');
            
            $responseTime = round((microtime(true) - $start) * 1000, 2);

            return [
                'status' => 'healthy',
                'details' => [
                    'driver' => $connection->getDriverName(),
                    'database' => $connection->getDatabaseName(),
                    'response_time_ms' => $responseTime,
                    'connection_status' => 'connected',
                ],
            ];
        } catch (Exception $e) {
            return [
                'status' => 'unhealthy',
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check cache connectivity and performance
     *
     * @return array
     */
    private function checkCache(): array
    {
        try {
            $start = microtime(true);
            
            // Test cache operations
            $testKey = 'health_check_' . time();
            $testValue = 'test_value';
            
            Cache::put($testKey, $testValue, 60);
            $retrieved = Cache::get($testKey);
            Cache::forget($testKey);
            
            $responseTime = round((microtime(true) - $start) * 1000, 2);

            if ($retrieved !== $testValue) {
                throw new Exception('Cache value mismatch');
            }

            $details = [
                'driver' => config('cache.default'),
                'response_time_ms' => $responseTime,
                'operation_status' => 'successful',
            ];

            // Add Redis-specific checks if using Redis
            if (config('cache.default') === 'redis') {
                $redisInfo = $this->getRedisInfo();
                $details = array_merge($details, $redisInfo);
            }

            return [
                'status' => 'healthy',
                'details' => $details,
            ];
        } catch (Exception $e) {
            return [
                'status' => 'unhealthy',
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check storage accessibility
     *
     * @return array
     */
    private function checkStorage(): array
    {
        try {
            $storagePath = storage_path('app');
            $logPath = storage_path('logs');
            
            $checks = [
                'storage_writable' => is_writable($storagePath),
                'logs_writable' => is_writable($logPath),
                'storage_disk_space' => $this->getDiskSpace($storagePath),
            ];

            $allChecksPass = !in_array(false, $checks, true);

            return [
                'status' => $allChecksPass ? 'healthy' : 'unhealthy',
                'details' => $checks,
            ];
        } catch (Exception $e) {
            return [
                'status' => 'unhealthy',
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check external services connectivity
     *
     * @return array
     */
    private function checkExternalServices(): array
    {
        $services = [];

        // Check email service
        if (config('mail.default') !== 'log') {
            $services['email'] = $this->checkEmailService();
        }

        // Check payment services
        if (config('services.stripe.key')) {
            $services['stripe'] = $this->checkStripeService();
        }

        // Check AI services
        if (config('services.openai.key')) {
            $services['openai'] = $this->checkOpenAIService();
        }

        return $services;
    }

    /**
     * Get Redis connection information
     *
     * @return array
     */
    private function getRedisInfo(): array
    {
        try {
            $redis = Redis::connection();
            $info = $redis->info();
            
            return [
                'redis_version' => $info['redis_version'] ?? 'unknown',
                'connected_clients' => $info['connected_clients'] ?? 'unknown',
                'used_memory_human' => $info['used_memory_human'] ?? 'unknown',
            ];
        } catch (Exception $e) {
            return [
                'redis_error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get disk space information
     *
     * @param string $path
     * @return string
     */
    private function getDiskSpace(string $path): string
    {
        try {
            $freeBytes = disk_free_space($path);
            $totalBytes = disk_total_space($path);
            
            if ($freeBytes === false || $totalBytes === false) {
                return 'unknown';
            }
            
            $freeGB = round($freeBytes / 1024 / 1024 / 1024, 2);
            $totalGB = round($totalBytes / 1024 / 1024 / 1024, 2);
            $usagePercent = round((($totalBytes - $freeBytes) / $totalBytes) * 100, 2);
            
            return "{$freeGB}GB free of {$totalGB}GB ({$usagePercent}% used)";
        } catch (Exception $e) {
            return 'error: ' . $e->getMessage();
        }
    }

    /**
     * Check email service connectivity
     *
     * @return array
     */
    private function checkEmailService(): array
    {
        // This is a basic check - in production, you might want to send a test email
        return [
            'status' => 'not_implemented',
            'message' => 'Email service check not implemented',
        ];
    }

    /**
     * Check Stripe service connectivity
     *
     * @return array
     */
    private function checkStripeService(): array
    {
        // This would require making an API call to Stripe
        return [
            'status' => 'not_implemented',
            'message' => 'Stripe service check not implemented',
        ];
    }

    /**
     * Check OpenAI service connectivity
     *
     * @return array
     */
    private function checkOpenAIService(): array
    {
        // This would require making an API call to OpenAI
        return [
            'status' => 'not_implemented',
            'message' => 'OpenAI service check not implemented',
        ];
    }
}