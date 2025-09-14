<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('proposals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            $table->foreignId('freelancer_id')->constrained('users')->onDelete('cascade');
            $table->longText('cover_letter');
            $table->decimal('proposed_amount', 12, 2);
            $table->string('currency', 3)->default('BDT');
            $table->integer('delivery_time'); // in days
            $table->json('milestones')->nullable();
            $table->json('attachments')->nullable();
            $table->enum('status', ['pending', 'accepted', 'rejected', 'withdrawn'])->default('pending');
            $table->timestamp('submitted_at')->nullable();
            $table->integer('response_time_hours')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['job_id', 'status']);
            $table->index(['freelancer_id', 'status']);
            $table->unique(['job_id', 'freelancer_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('proposals');
    }
};