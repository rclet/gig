<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->nullable()->constrained()->onDelete('cascade');
            $table->foreignId('participant_one_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('participant_two_id')->constrained('users')->onDelete('cascade');
            $table->string('title')->nullable();
            $table->foreignId('last_message_id')->nullable()->constrained('messages')->onDelete('set null');
            $table->timestamp('last_message_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['participant_one_id', 'participant_two_id']);
            $table->index(['project_id', 'is_active']);
            $table->index(['last_message_at', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};