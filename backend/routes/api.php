<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\ProposalController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Public routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('reset-password', [AuthController::class, 'resetPassword']);
    Route::post('social-login', [AuthController::class, 'socialLogin']);
});

// Public job routes
Route::prefix('jobs')->group(function () {
    Route::get('/', [JobController::class, 'index']);
    Route::get('/{job}', [JobController::class, 'show']);
    Route::get('/category/{category}', [JobController::class, 'byCategory']);
    Route::get('/search', [JobController::class, 'search']);
});

// Public categories
Route::get('categories', [CategoryController::class, 'index']);
Route::get('categories/{category}', [CategoryController::class, 'show']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth management
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::get('me', [AuthController::class, 'me']);
        Route::post('verify-email', [AuthController::class, 'verifyEmail']);
        Route::post('resend-verification', [AuthController::class, 'resendVerification']);
        Route::post('enable-2fa', [AuthController::class, 'enableTwoFactor']);
        Route::post('disable-2fa', [AuthController::class, 'disableTwoFactor']);
    });

    // User management
    Route::prefix('users')->group(function () {
        Route::get('profile', [UserController::class, 'profile']);
        Route::put('profile', [UserController::class, 'updateProfile']);
        Route::post('avatar', [UserController::class, 'uploadAvatar']);
        Route::get('dashboard', [UserController::class, 'dashboard']);
        Route::get('analytics', [UserController::class, 'analytics']);
    });

    // Job management
    Route::prefix('jobs')->group(function () {
        Route::post('/', [JobController::class, 'store']);
        Route::put('/{job}', [JobController::class, 'update']);
        Route::delete('/{job}', [JobController::class, 'destroy']);
        Route::post('/{job}/bookmark', [JobController::class, 'bookmark']);
        Route::delete('/{job}/bookmark', [JobController::class, 'removeBookmark']);
        Route::get('/my-jobs', [JobController::class, 'myJobs']);
        Route::get('/bookmarked', [JobController::class, 'bookmarked']);
    });

    // Proposal management
    Route::prefix('proposals')->group(function () {
        Route::post('/', [ProposalController::class, 'store']);
        Route::get('/{proposal}', [ProposalController::class, 'show']);
        Route::put('/{proposal}', [ProposalController::class, 'update']);
        Route::delete('/{proposal}', [ProposalController::class, 'destroy']);
        Route::post('/{proposal}/accept', [ProposalController::class, 'accept']);
        Route::post('/{proposal}/reject', [ProposalController::class, 'reject']);
        Route::get('/my-proposals', [ProposalController::class, 'myProposals']);
        Route::get('/job/{job}', [ProposalController::class, 'jobProposals']);
    });

    // Project management
    Route::prefix('projects')->group(function () {
        Route::get('/', [ProjectController::class, 'index']);
        Route::get('/{project}', [ProjectController::class, 'show']);
        Route::put('/{project}', [ProjectController::class, 'update']);
        Route::post('/{project}/complete', [ProjectController::class, 'complete']);
        Route::post('/{project}/cancel', [ProjectController::class, 'cancel']);
        Route::post('/{project}/rate', [ProjectController::class, 'rate']);
        Route::get('/{project}/messages', [ProjectController::class, 'messages']);
        Route::post('/{project}/messages', [ProjectController::class, 'sendMessage']);
    });

    // Chat and messaging
    Route::prefix('chat')->group(function () {
        Route::get('/conversations', [ChatController::class, 'conversations']);
        Route::get('/conversations/{conversation}', [ChatController::class, 'show']);
        Route::post('/conversations', [ChatController::class, 'create']);
        Route::post('/conversations/{conversation}/messages', [ChatController::class, 'sendMessage']);
        Route::put('/conversations/{conversation}/read', [ChatController::class, 'markAsRead']);
    });

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::put('/{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/mark-all-read', [NotificationController::class, 'markAllAsRead']);
        Route::delete('/{notification}', [NotificationController::class, 'destroy']);
    });
});

// Admin routes
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('dashboard', [AdminController::class, 'dashboard']);
    Route::resource('users', AdminUserController::class);
    Route::resource('categories', AdminCategoryController::class);
    Route::get('analytics', [AdminController::class, 'analytics']);
    Route::get('reports', [AdminController::class, 'reports']);
});