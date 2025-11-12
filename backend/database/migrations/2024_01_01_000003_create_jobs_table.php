<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
            $table->string('title');
            $table->longText('description');
            $table->text('requirements')->nullable();
            $table->json('skills_required')->nullable();
            $table->enum('budget_type', ['fixed', 'hourly'])->default('fixed');
            $table->decimal('budget_min', 12, 2);
            $table->decimal('budget_max', 12, 2);
            $table->string('currency', 3)->default('BDT');
            $table->integer('duration_estimate')->nullable(); // in days
            $table->enum('experience_level', ['entry', 'intermediate', 'expert'])->default('intermediate');
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->foreignId('subcategory_id')->nullable()->constrained('categories')->onDelete('set null');
            $table->enum('location_type', ['remote', 'onsite', 'hybrid'])->default('remote');
            $table->string('location')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_urgent')->default(false);
            $table->enum('status', ['draft', 'published', 'in_progress', 'completed', 'cancelled'])->default('draft');
            $table->timestamp('published_at')->nullable();
            $table->timestamp('deadline')->nullable();
            $table->json('attachments')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['status', 'published_at']);
            $table->index(['category_id', 'status']);
            $table->index(['is_featured', 'status']);
            $table->index(['budget_min', 'budget_max']);
            
            // Only create fulltext index for MySQL
            if (config('database.default') === 'mysql') {
                $table->fullText(['title', 'description']);
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jobs');
    }
};