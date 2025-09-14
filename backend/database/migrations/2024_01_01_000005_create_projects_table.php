<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            $table->foreignId('proposal_id')->constrained()->onDelete('cascade');
            $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('freelancer_id')->constrained('users')->onDelete('cascade');
            $table->string('title');
            $table->longText('description');
            $table->decimal('budget', 12, 2);
            $table->string('currency', 3)->default('BDT');
            $table->enum('status', ['active', 'completed', 'cancelled', 'disputed'])->default('active');
            $table->timestamp('start_date')->nullable();
            $table->timestamp('deadline')->nullable();
            $table->timestamp('completion_date')->nullable();
            $table->integer('progress_percentage')->default(0);
            $table->json('milestones')->nullable();
            $table->json('deliverables')->nullable();
            $table->integer('client_rating')->nullable();
            $table->integer('freelancer_rating')->nullable();
            $table->text('client_feedback')->nullable();
            $table->text('freelancer_feedback')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['client_id', 'status']);
            $table->index(['freelancer_id', 'status']);
            $table->index(['status', 'deadline']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};