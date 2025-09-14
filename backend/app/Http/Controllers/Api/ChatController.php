<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get user's conversations.
     */
    public function conversations(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $conversations = Conversation::with([
                'participantOne:id,first_name,last_name,avatar',
                'participantTwo:id,first_name,last_name,avatar',
                'lastMessage:id,content,message_type,created_at,sender_id',
                'project:id,title'
            ])
            ->forUser($user)
            ->active()
            ->orderBy('last_message_at', 'desc')
            ->paginate(20);

        // Add unread count and other participant info for each conversation
        $conversations->getCollection()->transform(function ($conversation) use ($user) {
            $otherParticipant = $conversation->getOtherParticipant($user);
            $conversation->other_participant = $otherParticipant;
            $conversation->unread_count = $conversation->unreadMessagesCount($user);
            return $conversation;
        });

        return response()->json([
            'conversations' => $conversations->items(),
            'pagination' => [
                'current_page' => $conversations->currentPage(),
                'last_page' => $conversations->lastPage(),
                'per_page' => $conversations->perPage(),
                'total' => $conversations->total(),
            ]
        ]);
    }

    /**
     * Get a specific conversation with messages.
     */
    public function show(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();
        
        if (!$conversation->hasParticipant($user)) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $conversation->load([
            'participantOne:id,first_name,last_name,avatar',
            'participantTwo:id,first_name,last_name,avatar',
            'project:id,title'
        ]);

        $messages = $conversation->messages()
                                ->with('sender:id,first_name,last_name,avatar')
                                ->orderBy('created_at', 'desc')
                                ->paginate(50);

        // Mark messages as read
        $conversation->markAllAsRead($user);

        $otherParticipant = $conversation->getOtherParticipant($user);

        return response()->json([
            'conversation' => [
                'id' => $conversation->id,
                'title' => $conversation->title,
                'project' => $conversation->project,
                'other_participant' => $otherParticipant,
                'created_at' => $conversation->created_at,
                'updated_at' => $conversation->updated_at,
            ],
            'messages' => array_reverse($messages->items()),
            'pagination' => [
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
                'per_page' => $messages->perPage(),
                'total' => $messages->total(),
            ]
        ]);
    }

    /**
     * Create a new conversation.
     */
    public function create(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'participant_id' => 'required|exists:users,id|different:user_id',
            'project_id' => 'nullable|exists:projects,id',
            'initial_message' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $participantId = $request->participant_id;

        // Check if conversation already exists
        $existingConversation = Conversation::where(function ($query) use ($user, $participantId) {
                $query->where('participant_one_id', $user->id)
                      ->where('participant_two_id', $participantId);
            })
            ->orWhere(function ($query) use ($user, $participantId) {
                $query->where('participant_one_id', $participantId)
                      ->where('participant_two_id', $user->id);
            })
            ->where('project_id', $request->project_id)
            ->first();

        if ($existingConversation) {
            return response()->json([
                'message' => 'Conversation already exists',
                'conversation' => $existingConversation
            ], 409);
        }

        // Create new conversation
        $conversation = Conversation::create([
            'participant_one_id' => $user->id,
            'participant_two_id' => $participantId,
            'project_id' => $request->project_id,
        ]);

        // Send initial message
        $message = $conversation->sendMessage(
            $user, 
            $request->initial_message
        );

        $conversation->load([
            'participantOne:id,first_name,last_name,avatar',
            'participantTwo:id,first_name,last_name,avatar',
            'project:id,title'
        ]);

        return response()->json([
            'message' => 'Conversation created successfully',
            'conversation' => $conversation,
            'initial_message' => $message
        ], 201);
    }

    /**
     * Send a message in a conversation.
     */
    public function sendMessage(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();
        
        if (!$conversation->hasParticipant($user)) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:5000',
            'message_type' => 'nullable|in:text,image,file',
            'attachments' => 'nullable|array',
            'attachments.*' => 'string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $message = $conversation->sendMessage(
            $user,
            $request->content,
            $request->message_type ?? 'text',
            $request->attachments ?? []
        );

        $message->load('sender:id,first_name,last_name,avatar');

        // TODO: Send real-time notification via WebSocket or Pusher

        return response()->json([
            'message' => 'Message sent successfully',
            'data' => $message
        ], 201);
    }

    /**
     * Mark conversation as read.
     */
    public function markAsRead(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();
        
        if (!$conversation->hasParticipant($user)) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $conversation->markAllAsRead($user);

        return response()->json([
            'message' => 'Conversation marked as read'
        ]);
    }

    /**
     * Get unread messages count.
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $totalUnread = Message::where('recipient_id', $user->id)
                             ->unread()
                             ->count();

        $conversationsWithUnread = Conversation::forUser($user)
                                             ->active()
                                             ->whereHas('messages', function ($query) use ($user) {
                                                 $query->where('recipient_id', $user->id)
                                                       ->unread();
                                             })
                                             ->count();

        return response()->json([
            'total_unread_messages' => $totalUnread,
            'conversations_with_unread' => $conversationsWithUnread
        ]);
    }
}