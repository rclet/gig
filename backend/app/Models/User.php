<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'phone',
        'password',
        'avatar',
        'bio',
        'skills',
        'location',
        'timezone',
        'hourly_rate',
        'currency',
        'is_verified',
        'is_active',
        'last_seen_at',
        'profile_completion_score',
        'email_verified_at',
        'phone_verified_at',
        'social_provider',
        'social_provider_id',
        'preferences',
        'two_factor_enabled',
        'two_factor_secret',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_secret',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'password' => 'hashed',
            'skills' => 'array',
            'preferences' => 'array',
            'is_verified' => 'boolean',
            'is_active' => 'boolean',
            'two_factor_enabled' => 'boolean',
            'last_seen_at' => 'datetime',
            'hourly_rate' => 'decimal:2',
            'profile_completion_score' => 'integer',
        ];
    }

    /**
     * Get the user's full name.
     */
    public function getFullNameAttribute(): string
    {
        return $this->first_name . ' ' . $this->last_name;
    }

    /**
     * Check if user is a freelancer.
     */
    public function isFreelancer(): bool
    {
        return $this->hasRole('freelancer');
    }

    /**
     * Check if user is a client.
     */
    public function isClient(): bool
    {
        return $this->hasRole('client');
    }

    /**
     * Check if user is an admin.
     */
    public function isAdmin(): bool
    {
        return $this->hasRole('admin');
    }

    /**
     * Get the user's jobs (if client).
     */
    public function jobs()
    {
        return $this->hasMany(Job::class, 'client_id');
    }

    /**
     * Get the user's proposals (if freelancer).
     */
    public function proposals()
    {
        return $this->hasMany(Proposal::class, 'freelancer_id');
    }

    /**
     * Get the user's active projects.
     */
    public function activeProjects()
    {
        return $this->projects()->where('status', 'active');
    }

    /**
     * Get all projects (both as client and freelancer).
     */
    public function projects()
    {
        return $this->hasMany(Project::class, 'client_id')
            ->orWhere('freelancer_id', $this->id);
    }

    /**
     * Get the user's reviews received.
     */
    public function reviewsReceived()
    {
        return $this->hasMany(Review::class, 'reviewed_user_id');
    }

    /**
     * Get the user's reviews given.
     */
    public function reviewsGiven()
    {
        return $this->hasMany(Review::class, 'reviewer_id');
    }

    /**
     * Get the user's portfolio items.
     */
    public function portfolioItems()
    {
        return $this->hasMany(PortfolioItem::class);
    }

    /**
     * Get the user's messages sent.
     */
    public function messagesSent()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    /**
     * Get the user's messages received.
     */
    public function messagesReceived()
    {
        return $this->hasMany(Message::class, 'recipient_id');
    }

    /**
     * Get the user's notifications.
     */
    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Calculate profile completion percentage.
     */
    public function calculateProfileCompletion(): int
    {
        $fields = [
            'first_name', 'last_name', 'email', 'phone', 'bio', 
            'skills', 'location', 'avatar'
        ];
        
        $completed = 0;
        foreach ($fields as $field) {
            if (!empty($this->$field)) {
                $completed++;
            }
        }
        
        // Add bonus for verification
        if ($this->email_verified_at) $completed += 0.5;
        if ($this->phone_verified_at) $completed += 0.5;
        
        return min(100, round(($completed / count($fields)) * 100));
    }

    /**
     * Update last seen timestamp.
     */
    public function updateLastSeen(): void
    {
        $this->update(['last_seen_at' => now()]);
    }

    /**
     * Scope for active users.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for verified users.
     */
    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    /**
     * Scope for freelancers.
     */
    public function scopeFreelancers($query)
    {
        return $query->role('freelancer');
    }

    /**
     * Scope for clients.
     */
    public function scopeClients($query)
    {
        return $query->role('client');
    }
}