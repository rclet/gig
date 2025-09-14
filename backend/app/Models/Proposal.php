<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Proposal extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'job_id',
        'freelancer_id',
        'cover_letter',
        'proposed_amount',
        'currency',
        'delivery_time', // in days
        'milestones',
        'attachments',
        'status', // pending, accepted, rejected, withdrawn
        'submitted_at',
        'response_time_hours',
    ];

    protected function casts(): array
    {
        return [
            'milestones' => 'array',
            'attachments' => 'array',
            'submitted_at' => 'datetime',
            'proposed_amount' => 'decimal:2',
            'delivery_time' => 'integer',
            'response_time_hours' => 'integer',
        ];
    }

    /**
     * Get the job this proposal is for.
     */
    public function job()
    {
        return $this->belongsTo(Job::class);
    }

    /**
     * Get the freelancer who submitted this proposal.
     */
    public function freelancer()
    {
        return $this->belongsTo(User::class, 'freelancer_id');
    }

    /**
     * Get the project created from this proposal (if accepted).
     */
    public function project()
    {
        return $this->hasOne(Project::class);
    }

    /**
     * Scope for accepted proposals.
     */
    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    /**
     * Scope for pending proposals.
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Check if proposal can be withdrawn.
     */
    public function canBeWithdrawn(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if proposal can be accepted.
     */
    public function canBeAccepted(): bool
    {
        return $this->status === 'pending' && $this->job->isAcceptingProposals();
    }

    /**
     * Accept this proposal.
     */
    public function accept(): Project
    {
        if (!$this->canBeAccepted()) {
            throw new \Exception('This proposal cannot be accepted.');
        }

        $this->update(['status' => 'accepted']);

        // Reject all other proposals for this job
        $this->job->proposals()
            ->where('id', '!=', $this->id)
            ->where('status', 'pending')
            ->update(['status' => 'rejected']);

        // Create project
        $project = Project::create([
            'job_id' => $this->job_id,
            'proposal_id' => $this->id,
            'client_id' => $this->job->client_id,
            'freelancer_id' => $this->freelancer_id,
            'title' => $this->job->title,
            'description' => $this->job->description,
            'budget' => $this->proposed_amount,
            'currency' => $this->currency,
            'status' => 'active',
            'start_date' => now(),
            'deadline' => now()->addDays($this->delivery_time),
        ]);

        // Update job status
        $this->job->update(['status' => 'in_progress']);

        return $project;
    }

    /**
     * Get formatted proposal amount.
     */
    public function getFormattedAmountAttribute(): string
    {
        return $this->currency . ' ' . number_format($this->proposed_amount, 2);
    }
}