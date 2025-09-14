<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Project extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'job_id',
        'proposal_id',
        'client_id',
        'freelancer_id',
        'title',
        'description',
        'budget',
        'currency',
        'status', // active, completed, cancelled, disputed
        'start_date',
        'deadline',
        'completion_date',
        'progress_percentage',
        'milestones',
        'deliverables',
        'client_rating',
        'freelancer_rating',
        'client_feedback',
        'freelancer_feedback',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'datetime',
            'deadline' => 'datetime',
            'completion_date' => 'datetime',
            'budget' => 'decimal:2',
            'progress_percentage' => 'integer',
            'milestones' => 'array',
            'deliverables' => 'array',
            'client_rating' => 'integer',
            'freelancer_rating' => 'integer',
        ];
    }

    /**
     * Get the original job.
     */
    public function job()
    {
        return $this->belongsTo(Job::class);
    }

    /**
     * Get the accepted proposal.
     */
    public function proposal()
    {
        return $this->belongsTo(Proposal::class);
    }

    /**
     * Get the client.
     */
    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    /**
     * Get the freelancer.
     */
    public function freelancer()
    {
        return $this->belongsTo(User::class, 'freelancer_id');
    }

    /**
     * Get project milestones.
     */
    public function projectMilestones()
    {
        return $this->hasMany(ProjectMilestone::class);
    }

    /**
     * Get project messages.
     */
    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    /**
     * Get project files.
     */
    public function files()
    {
        return $this->hasMany(ProjectFile::class);
    }

    /**
     * Get project invoices.
     */
    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    /**
     * Scope for active projects.
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope for completed projects.
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Check if project is overdue.
     */
    public function isOverdue(): bool
    {
        return $this->status === 'active' && 
               $this->deadline && 
               $this->deadline < now();
    }

    /**
     * Update project progress.
     */
    public function updateProgress(int $percentage): void
    {
        $this->update(['progress_percentage' => min(100, max(0, $percentage))]);
        
        if ($percentage >= 100 && $this->status === 'active') {
            $this->markAsCompleted();
        }
    }

    /**
     * Mark project as completed.
     */
    public function markAsCompleted(): void
    {
        $this->update([
            'status' => 'completed',
            'completion_date' => now(),
            'progress_percentage' => 100,
        ]);
    }

    /**
     * Get formatted budget.
     */
    public function getFormattedBudgetAttribute(): string
    {
        return $this->currency . ' ' . number_format($this->budget, 2);
    }
}