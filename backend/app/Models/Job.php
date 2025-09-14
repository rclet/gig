<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Job extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'client_id',
        'title',
        'description',
        'requirements',
        'skills_required',
        'budget_type', // fixed, hourly
        'budget_min',
        'budget_max',
        'currency',
        'duration_estimate',
        'experience_level', // entry, intermediate, expert
        'category_id',
        'subcategory_id',
        'location_type', // remote, onsite, hybrid
        'location',
        'is_featured',
        'is_urgent',
        'status', // draft, published, in_progress, completed, cancelled
        'published_at',
        'deadline',
        'attachments',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'skills_required' => 'array',
            'attachments' => 'array',
            'metadata' => 'array',
            'is_featured' => 'boolean',
            'is_urgent' => 'boolean',
            'published_at' => 'datetime',
            'deadline' => 'datetime',
            'budget_min' => 'decimal:2',
            'budget_max' => 'decimal:2',
        ];
    }

    /**
     * Get the client who posted this job.
     */
    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    /**
     * Get the job category.
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Get the job subcategory.
     */
    public function subcategory()
    {
        return $this->belongsTo(Category::class, 'subcategory_id');
    }

    /**
     * Get all proposals for this job.
     */
    public function proposals()
    {
        return $this->hasMany(Proposal::class);
    }

    /**
     * Get the accepted proposal (if any).
     */
    public function acceptedProposal()
    {
        return $this->hasOne(Proposal::class)->where('status', 'accepted');
    }

    /**
     * Get the project created from this job.
     */
    public function project()
    {
        return $this->hasOne(Project::class);
    }

    /**
     * Get job views/analytics.
     */
    public function views()
    {
        return $this->hasMany(JobView::class);
    }

    /**
     * Get job bookmarks.
     */
    public function bookmarks()
    {
        return $this->hasMany(JobBookmark::class);
    }

    /**
     * Scope for published jobs.
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published')
                    ->whereNotNull('published_at')
                    ->where('published_at', '<=', now());
    }

    /**
     * Scope for featured jobs.
     */
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    /**
     * Scope for urgent jobs.
     */
    public function scopeUrgent($query)
    {
        return $query->where('is_urgent', true);
    }

    /**
     * Scope for jobs by budget range.
     */
    public function scopeByBudgetRange($query, $min = null, $max = null)
    {
        if ($min) {
            $query->where('budget_min', '>=', $min);
        }
        if ($max) {
            $query->where('budget_max', '<=', $max);
        }
        return $query;
    }

    /**
     * Scope for jobs by skills.
     */
    public function scopeBySkills($query, array $skills)
    {
        foreach ($skills as $skill) {
            $query->whereJsonContains('skills_required', $skill);
        }
        return $query;
    }

    /**
     * Get formatted budget display.
     */
    public function getFormattedBudgetAttribute(): string
    {
        if ($this->budget_type === 'fixed') {
            if ($this->budget_min === $this->budget_max) {
                return $this->currency . ' ' . number_format($this->budget_min, 2);
            }
            return $this->currency . ' ' . number_format($this->budget_min, 2) . ' - ' . number_format($this->budget_max, 2);
        }
        
        return $this->currency . ' ' . number_format($this->budget_min, 2) . ' - ' . number_format($this->budget_max, 2) . '/hr';
    }

    /**
     * Check if job is still accepting proposals.
     */
    public function isAcceptingProposals(): bool
    {
        return $this->status === 'published' && 
               (!$this->deadline || $this->deadline > now()) &&
               !$this->acceptedProposal;
    }

    /**
     * Increment view count.
     */
    public function incrementViews(User $user = null): void
    {
        JobView::create([
            'job_id' => $this->id,
            'user_id' => $user?->id,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}