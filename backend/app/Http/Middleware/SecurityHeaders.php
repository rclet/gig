<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityHeaders
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Security headers configuration
        $securityConfig = config('security.headers');

        // X-Frame-Options
        if (isset($securityConfig['x_frame_options'])) {
            $response->headers->set('X-Frame-Options', $securityConfig['x_frame_options']);
        }

        // X-Content-Type-Options
        if (isset($securityConfig['x_content_type_options'])) {
            $response->headers->set('X-Content-Type-Options', $securityConfig['x_content_type_options']);
        }

        // X-XSS-Protection
        if (isset($securityConfig['x_xss_protection'])) {
            $response->headers->set('X-XSS-Protection', $securityConfig['x_xss_protection']);
        }

        // Referrer-Policy
        if (isset($securityConfig['referrer_policy'])) {
            $response->headers->set('Referrer-Policy', $securityConfig['referrer_policy']);
        }

        // Permissions-Policy
        if (isset($securityConfig['permissions_policy'])) {
            $response->headers->set('Permissions-Policy', $securityConfig['permissions_policy']);
        }

        // Strict-Transport-Security (HSTS)
        if (isset($securityConfig['strict_transport_security']) && 
            $securityConfig['strict_transport_security']['enabled'] && 
            $request->isSecure()) {
            $hstsConfig = $securityConfig['strict_transport_security'];
            $hstsValue = 'max-age=' . $hstsConfig['max_age'];
            
            if ($hstsConfig['include_subdomains']) {
                $hstsValue .= '; includeSubDomains';
            }
            
            if ($hstsConfig['preload']) {
                $hstsValue .= '; preload';
            }
            
            $response->headers->set('Strict-Transport-Security', $hstsValue);
        }

        // Content Security Policy
        $cspConfig = config('security.csp');
        if ($cspConfig['enabled']) {
            $cspDirectives = [];
            foreach ($cspConfig['directives'] as $directive => $value) {
                $cspDirectives[] = str_replace('_', '-', $directive) . ' ' . $value;
            }
            
            $cspHeader = implode('; ', $cspDirectives);
            $headerName = $cspConfig['report_only'] ? 'Content-Security-Policy-Report-Only' : 'Content-Security-Policy';
            $response->headers->set($headerName, $cspHeader);
        }

        return $response;
    }
}