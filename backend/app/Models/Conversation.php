<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Conversation extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'project_id',
        'participant_one_id',
        'participant_two_id',
        'title',
        'last_message_id',
        'last_message_at',
        'is_active',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'last_message_at' => 'datetime',
            'is_active' => 'boolean',
            'metadata' => 'array',
        ];
    }

    /**
     * Get the project this conversation is related to.
     */
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    /**
     * Get the first participant.
     */
    public function participantOne()
    {
        return $this->belongsTo(User::class, 'participant_one_id');
    }

    /**
     * Get the second participant.
     */
    public function participantTwo()
    {
        return $this->belongsTo(User::class, 'participant_two_id');
    }

    /**
     * Get the last message in the conversation.
     */
    public function lastMessage()
    {
        return $this->belongsTo(Message::class, 'last_message_id');
    }

    /**
     * Get all messages in this conversation.
     */
    public function messages()
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'asc');
    }

    /**
     * Get unread messages count for a specific user.
     */
    public function unreadMessagesCount(User $user): int
    {
        return $this->messages()
                   ->where('recipient_id', $user->id)
                   ->unread()
                   ->count();
    }

    /**
     * Get the other participant in the conversation.
     */
    public function getOtherParticipant(User $user): ?User
    {
        if ($this->participant_one_id === $user->id) {
            return $this->participantTwo;
        } elseif ($this->participant_two_id === $user->id) {
            return $this->participantOne;
        }
        
        return null;
    }

    /**
     * Check if user is a participant in this conversation.
     */
    public function hasParticipant(User $user): bool
    {
        return $this->participant_one_id === $user->id || 
               $this->participant_two_id === $user->id;
    }

    /**
     * Mark all messages as read for a specific user.
     */
    public function markAllAsRead(User $user): void
    {
        $this->messages()
             ->where('recipient_id', $user->id)
             ->unread()
             ->update(['read_at' => now()]);
    }

    /**
     * Send a message in this conversation.
     */
    public function sendMessage(User $sender, string $content, string $type = 'text', array $attachments = []): Message
    {
        $recipient = $this->getOtherParticipant($sender);
        
        $message = $this->messages()->create([
            'sender_id' => $sender->id,
            'recipient_id' => $recipient->id,
            'project_id' => $this->project_id,
            'content' => $content,
            'message_type' => $type,
            'attachments' => $attachments,
        ]);

        // Update conversation last message
        $this->update([
            'last_message_id' => $message->id,
            'last_message_at' => now(),
        ]);

        return $message;
    }

    /**
     * Scope for active conversations.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for conversations involving a specific user.
     */
    public function scopeForUser($query, User $user)
    {
        return $query->where('participant_one_id', $user->id)
                    ->orWhere('participant_two_id', $user->id);
    }
}