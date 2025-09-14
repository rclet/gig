<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Job;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class JobController extends Controller
{
    /**
     * Display a listing of jobs.
     */
    public function index(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'category_id' => 'nullable|exists:categories,id',
            'budget_min' => 'nullable|numeric|min:0',
            'budget_max' => 'nullable|numeric|min:0',
            'budget_type' => 'nullable|in:fixed,hourly',
            'experience_level' => 'nullable|in:entry,intermediate,expert',
            'location_type' => 'nullable|in:remote,onsite,hybrid',
            'skills' => 'nullable|array',
            'skills.*' => 'string',
            'sort_by' => 'nullable|in:latest,budget_asc,budget_desc,deadline',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = Job::with(['client:id,first_name,last_name,avatar', 'category:id,name,slug'])
                    ->published();

        // Apply filters
        if ($request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->budget_min || $request->budget_max) {
            $query->byBudgetRange($request->budget_min, $request->budget_max);
        }

        if ($request->budget_type) {
            $query->where('budget_type', $request->budget_type);
        }

        if ($request->experience_level) {
            $query->where('experience_level', $request->experience_level);
        }

        if ($request->location_type) {
            $query->where('location_type', $request->location_type);
        }

        if ($request->skills) {
            $query->bySkills($request->skills);
        }

        // Apply sorting
        switch ($request->sort_by) {
            case 'budget_asc':
                $query->orderBy('budget_min', 'asc');
                break;
            case 'budget_desc':
                $query->orderBy('budget_max', 'desc');
                break;
            case 'deadline':
                $query->orderBy('deadline', 'asc');
                break;
            default:
                $query->latest();
        }

        // Prioritize featured and urgent jobs
        $query->orderBy('is_featured', 'desc')
              ->orderBy('is_urgent', 'desc');

        $jobs = $query->paginate($request->per_page ?? 20);

        return response()->json([
            'jobs' => $jobs->items(),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }

    /**
     * Store a newly created job.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string|min:50',
            'requirements' => 'nullable|string',
            'skills_required' => 'required|array|min:1',
            'skills_required.*' => 'string|max:50',
            'budget_type' => 'required|in:fixed,hourly',
            'budget_min' => 'required|numeric|min:0',
            'budget_max' => 'required|numeric|min:0|gte:budget_min',
            'currency' => 'required|string|size:3',
            'duration_estimate' => 'nullable|integer|min:1',
            'experience_level' => 'required|in:entry,intermediate,expert',
            'category_id' => 'required|exists:categories,id',
            'subcategory_id' => 'nullable|exists:categories,id',
            'location_type' => 'required|in:remote,onsite,hybrid',
            'location' => 'required_if:location_type,onsite,hybrid|nullable|string|max:255',
            'deadline' => 'nullable|date|after:today',
            'attachments' => 'nullable|array',
            'is_urgent' => 'boolean',
            'publish_now' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        
        if (!$user->isClient()) {
            return response()->json([
                'message' => 'Only clients can post jobs'
            ], 403);
        }

        $jobData = $validator->validated();
        $jobData['client_id'] = $user->id;
        
        if ($request->publish_now) {
            $jobData['status'] = 'published';
            $jobData['published_at'] = now();
        }

        $job = Job::create($jobData);

        return response()->json([
            'message' => 'Job created successfully',
            'job' => $job->load(['client:id,first_name,last_name', 'category:id,name'])
        ], 201);
    }

    /**
     * Display the specified job.
     */
    public function show(Request $request, Job $job): JsonResponse
    {
        if ($job->status !== 'published' && $job->client_id !== $request->user()?->id) {
            return response()->json([
                'message' => 'Job not found'
            ], 404);
        }

        // Increment view count
        if ($request->user() && $request->user()->id !== $job->client_id) {
            $job->incrementViews($request->user());
        }

        $job->load([
            'client:id,first_name,last_name,avatar,location',
            'category:id,name,slug',
            'subcategory:id,name,slug',
            'proposals' => function ($query) {
                $query->with('freelancer:id,first_name,last_name,avatar')
                      ->where('status', 'pending')
                      ->latest();
            }
        ]);

        return response()->json([
            'job' => $job
        ]);
    }

    /**
     * Update the specified job.
     */
    public function update(Request $request, Job $job): JsonResponse
    {
        if ($job->client_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($job->status === 'in_progress' || $job->status === 'completed') {
            return response()->json([
                'message' => 'Cannot update job that is in progress or completed'
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'string|max:255',
            'description' => 'string|min:50',
            'requirements' => 'nullable|string',
            'skills_required' => 'array|min:1',
            'skills_required.*' => 'string|max:50',
            'budget_type' => 'in:fixed,hourly',
            'budget_min' => 'numeric|min:0',
            'budget_max' => 'numeric|min:0',
            'deadline' => 'nullable|date|after:today',
            'is_urgent' => 'boolean',
            'status' => 'in:draft,published',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $validator->validated();
        
        if (isset($updateData['status']) && $updateData['status'] === 'published') {
            $updateData['published_at'] = now();
        }

        $job->update($updateData);

        return response()->json([
            'message' => 'Job updated successfully',
            'job' => $job->fresh(['client:id,first_name,last_name', 'category:id,name'])
        ]);
    }

    /**
     * Remove the specified job.
     */
    public function destroy(Request $request, Job $job): JsonResponse
    {
        if ($job->client_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($job->status === 'in_progress') {
            return response()->json([
                'message' => 'Cannot delete job that is in progress'
            ], 422);
        }

        $job->delete();

        return response()->json([
            'message' => 'Job deleted successfully'
        ]);
    }

    /**
     * Get jobs by category.
     */
    public function byCategory(Request $request, Category $category): JsonResponse
    {
        $jobs = Job::with(['client:id,first_name,last_name,avatar', 'category:id,name'])
                   ->where('category_id', $category->id)
                   ->published()
                   ->latest()
                   ->paginate(20);

        return response()->json([
            'category' => $category,
            'jobs' => $jobs->items(),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }

    /**
     * Search jobs.
     */
    public function search(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'q' => 'required|string|min:2',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $searchTerm = $request->q;
        
        $jobs = Job::with(['client:id,first_name,last_name,avatar', 'category:id,name'])
                   ->published()
                   ->where(function ($query) use ($searchTerm) {
                       $query->where('title', 'like', "%{$searchTerm}%")
                             ->orWhere('description', 'like', "%{$searchTerm}%")
                             ->orWhereJsonContains('skills_required', $searchTerm);
                   })
                   ->latest()
                   ->paginate($request->per_page ?? 20);

        return response()->json([
            'search_term' => $searchTerm,
            'jobs' => $jobs->items(),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }

    /**
     * Get user's jobs.
     */
    public function myJobs(Request $request): JsonResponse
    {
        $user = $request->user();
        
        if (!$user->isClient()) {
            return response()->json([
                'message' => 'Only clients can view their jobs'
            ], 403);
        }

        $jobs = $user->jobs()
                     ->with(['category:id,name', 'proposals'])
                     ->latest()
                     ->paginate(20);

        return response()->json([
            'jobs' => $jobs->items(),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }
}