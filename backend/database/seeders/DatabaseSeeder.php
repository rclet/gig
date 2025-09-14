<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Category;
use App\Models\Job;
use App\Models\Proposal;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create roles and permissions
        $this->createRolesAndPermissions();
        
        // Create categories
        $this->createCategories();
        
        // Create users
        $this->createUsers();
        
        // Create sample jobs
        $this->createSampleJobs();
    }

    private function createRolesAndPermissions(): void
    {
        // Create roles
        $adminRole = Role::create(['name' => 'admin']);
        $clientRole = Role::create(['name' => 'client']);
        $freelancerRole = Role::create(['name' => 'freelancer']);

        // Create permissions
        $permissions = [
            'manage-users',
            'manage-jobs',
            'manage-categories',
            'view-analytics',
            'post-jobs',
            'submit-proposals',
            'manage-projects',
            'send-messages',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Assign permissions to roles
        $adminRole->givePermissionTo($permissions);
        $clientRole->givePermissionTo(['post-jobs', 'manage-projects', 'send-messages']);
        $freelancerRole->givePermissionTo(['submit-proposals', 'manage-projects', 'send-messages']);
    }

    private function createCategories(): void
    {
        $categories = [
            [
                'name' => 'Web Development',
                'slug' => 'web-development',
                'description' => 'Frontend, Backend, and Full-stack web development',
                'icon' => 'code',
                'subcategories' => [
                    'Frontend Development',
                    'Backend Development',
                    'Full-stack Development',
                    'WordPress Development',
                    'E-commerce Development',
                ]
            ],
            [
                'name' => 'Mobile Development',
                'slug' => 'mobile-development',
                'description' => 'iOS, Android, and cross-platform mobile apps',
                'icon' => 'smartphone',
                'subcategories' => [
                    'iOS Development',
                    'Android Development',
                    'Flutter Development',
                    'React Native Development',
                ]
            ],
            [
                'name' => 'UI/UX Design',
                'slug' => 'ui-ux-design',
                'description' => 'User interface and user experience design',
                'icon' => 'palette',
                'subcategories' => [
                    'Web Design',
                    'Mobile App Design',
                    'Wireframing',
                    'Prototyping',
                    'User Research',
                ]
            ],
            [
                'name' => 'Graphic Design',
                'slug' => 'graphic-design',
                'description' => 'Logo, branding, and visual design services',
                'icon' => 'image',
                'subcategories' => [
                    'Logo Design',
                    'Brand Identity',
                    'Print Design',
                    'Illustration',
                    'Packaging Design',
                ]
            ],
            [
                'name' => 'Digital Marketing',
                'slug' => 'digital-marketing',
                'description' => 'SEO, social media, and online marketing',
                'icon' => 'trending_up',
                'subcategories' => [
                    'SEO',
                    'Social Media Marketing',
                    'Content Marketing',
                    'Email Marketing',
                    'PPC Advertising',
                ]
            ],
            [
                'name' => 'Content Writing',
                'slug' => 'content-writing',
                'description' => 'Blog posts, articles, and copywriting',
                'icon' => 'edit',
                'subcategories' => [
                    'Blog Writing',
                    'Technical Writing',
                    'Copywriting',
                    'Creative Writing',
                    'Translation',
                ]
            ],
        ];

        foreach ($categories as $categoryData) {
            $category = Category::create([
                'name' => $categoryData['name'],
                'slug' => $categoryData['slug'],
                'description' => $categoryData['description'],
                'icon' => $categoryData['icon'],
                'is_active' => true,
                'sort_order' => 0,
            ]);

            // Create subcategories
            foreach ($categoryData['subcategories'] as $index => $subcategoryName) {
                Category::create([
                    'name' => $subcategoryName,
                    'slug' => str()->slug($subcategoryName),
                    'parent_id' => $category->id,
                    'is_active' => true,
                    'sort_order' => $index,
                ]);
            }
        }
    }

    private function createUsers(): void
    {
        // Create admin user
        $admin = User::create([
            'first_name' => 'Super',
            'last_name' => 'Admin',
            'email' => 'admin@gig.com.bd',
            'password' => Hash::make('password'),
            'email_verified_at' => now(),
            'is_verified' => true,
            'location' => 'Dhaka, Bangladesh',
        ]);
        $admin->assignRole('admin');

        // Create sample clients
        $clients = [
            [
                'first_name' => 'Rashid',
                'last_name' => 'Ahmed',
                'email' => 'rashid@example.com',
                'location' => 'Dhaka, Bangladesh',
            ],
            [
                'first_name' => 'Fatima',
                'last_name' => 'Khan',
                'email' => 'fatima@example.com',
                'location' => 'Chittagong, Bangladesh',
            ],
        ];

        foreach ($clients as $clientData) {
            $client = User::create(array_merge($clientData, [
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'is_verified' => true,
            ]));
            $client->assignRole('client');
        }

        // Create sample freelancers
        $freelancers = [
            [
                'first_name' => 'Karim',
                'last_name' => 'Rahman',
                'email' => 'karim@example.com',
                'location' => 'Dhaka, Bangladesh',
                'skills' => ['Laravel', 'PHP', 'Vue.js', 'MySQL'],
                'hourly_rate' => 15.00,
                'bio' => 'Full-stack developer with 5+ years of experience in Laravel and Vue.js.',
            ],
            [
                'first_name' => 'Sadia',
                'last_name' => 'Islam',
                'email' => 'sadia@example.com',
                'location' => 'Sylhet, Bangladesh',
                'skills' => ['UI/UX Design', 'Figma', 'Adobe XD', 'Photoshop'],
                'hourly_rate' => 12.00,
                'bio' => 'UI/UX designer passionate about creating beautiful and intuitive user experiences.',
            ],
            [
                'first_name' => 'Mahmud',
                'last_name' => 'Hassan',
                'email' => 'mahmud@example.com',
                'location' => 'Khulna, Bangladesh',
                'skills' => ['Flutter', 'Dart', 'Firebase', 'Mobile Development'],
                'hourly_rate' => 18.00,
                'bio' => 'Mobile app developer specializing in Flutter and cross-platform development.',
            ],
        ];

        foreach ($freelancers as $freelancerData) {
            $freelancer = User::create(array_merge($freelancerData, [
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'is_verified' => true,
            ]));
            $freelancer->assignRole('freelancer');
        }
    }

    private function createSampleJobs(): void
    {
        $clients = User::role('client')->get();
        $categories = Category::whereNull('parent_id')->get();

        $sampleJobs = [
            [
                'title' => 'E-commerce Website Development',
                'description' => 'Need a modern e-commerce website built with Laravel and Vue.js. Should include payment integration, inventory management, and admin dashboard.',
                'requirements' => 'Experience with Laravel, Vue.js, payment gateways, responsive design',
                'skills_required' => ['Laravel', 'Vue.js', 'MySQL', 'Payment Integration'],
                'budget_min' => 800.00,
                'budget_max' => 1200.00,
                'currency' => 'USD',
                'duration_estimate' => 30,
                'experience_level' => 'intermediate',
                'location_type' => 'remote',
                'deadline' => now()->addDays(45),
            ],
            [
                'title' => 'Mobile App UI/UX Design',
                'description' => 'Looking for a talented UI/UX designer to create a modern and intuitive design for our fintech mobile app.',
                'requirements' => 'Portfolio showcasing mobile app designs, experience with fintech apps preferred',
                'skills_required' => ['UI/UX Design', 'Figma', 'Mobile Design', 'Prototyping'],
                'budget_min' => 300.00,
                'budget_max' => 500.00,
                'currency' => 'USD',
                'duration_estimate' => 14,
                'experience_level' => 'expert',
                'location_type' => 'remote',
                'deadline' => now()->addDays(21),
            ],
            [
                'title' => 'Flutter Mobile App Development',
                'description' => 'Develop a cross-platform mobile app for food delivery service. Need both customer and delivery partner apps.',
                'requirements' => 'Strong Flutter experience, Firebase integration, real-time tracking',
                'skills_required' => ['Flutter', 'Dart', 'Firebase', 'Google Maps API'],
                'budget_min' => 1000.00,
                'budget_max' => 1500.00,
                'currency' => 'USD',
                'duration_estimate' => 60,
                'experience_level' => 'expert',
                'location_type' => 'remote',
                'deadline' => now()->addDays(75),
            ],
        ];

        foreach ($sampleJobs as $index => $jobData) {
            $client = $clients->get($index % $clients->count());
            $category = $categories->get($index % $categories->count());

            Job::create(array_merge($jobData, [
                'client_id' => $client->id,
                'category_id' => $category->id,
                'status' => 'published',
                'published_at' => now()->subDays(rand(1, 7)),
            ]));
        }
    }
}