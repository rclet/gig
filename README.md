# Gig Marketplace Platform

A comprehensive fullstack gig marketplace platform built with Laravel (backend) and Flutter (frontend) for freelancers and clients in Bangladesh.

## 🌟 Features

### 🔐 Authentication & User Management
- **Multi-role system**: Freelancer, Client, Admin roles with permission-based access
- **Social authentication**: Google, Facebook, LinkedIn login integration
- **Multi-factor authentication**: Enhanced security with 2FA support
- **Profile management**: Comprehensive user profiles with skill matching

### 🎯 Core Marketplace Features
- **Job posting & management**: Full-featured job posting with categories, skills, budgets
- **Bidding system**: Proposal submission and management for freelancers
- **Project management**: Milestone tracking, progress monitoring, deliverables
- **Invoice & payments**: Integrated payment processing with multi-currency support
- **Real-time chat**: WebSocket-powered messaging between clients and freelancers
- **Video calling**: Integrated video interviews and meetings
- **Rating & reviews**: Mutual feedback system for quality assurance

### 🤖 AI-Powered Features
- **Smart job matching**: AI algorithm to match freelancers with relevant jobs
- **GPT-powered content**: Automated job descriptions and cover letter assistance
- **Resume builder**: AI-assisted resume creation with live previews
- **Sentiment analysis**: Review sentiment tracking and fraud detection
- **Personalized recommendations**: ML-driven content and job suggestions

### 🎨 Modern UI/UX
- **Responsive design**: Mobile-first approach with tablet and desktop support
- **Dark/light themes**: System-aware theme switching with smooth transitions
- **Bangladeshi branding**: Custom color palette and typography for local identity
- **Glassmorphism effects**: Modern design with subtle blur and transparency
- **Micro-animations**: Smooth transitions, loading states, and interactions
- **Progressive Web App**: Offline support and native app-like experience

### 📱 Mobile-First Development
- **Flutter frontend**: Cross-platform app for iOS, Android, and Web
- **State management**: Riverpod for efficient state handling
- **Offline support**: Local caching with Hive for offline functionality
- **Push notifications**: Firebase-powered real-time notifications
- **File management**: Drag-and-drop portfolio and document uploads

## 🏗️ Architecture

### Backend (Laravel)
```
backend/
├── app/
│   ├── Http/Controllers/Api/     # RESTful API controllers
│   ├── Models/                   # Eloquent models (User, Job, Proposal, etc.)
│   ├── Services/                 # Business logic services
│   └── Notifications/            # Email and push notifications
├── database/
│   ├── migrations/               # Database schema migrations
│   └── seeders/                  # Sample data seeders
├── routes/
│   ├── api.php                   # API routes
│   └── web.php                   # Web routes
└── config/                       # Configuration files
```

### Frontend (Flutter)
```
frontend/
├── lib/
│   ├── core/                     # Core utilities and services
│   │   ├── theme/                # App theming and colors
│   │   ├── routing/              # Navigation and routing
│   │   ├── services/             # API and storage services
│   │   └── constants/            # App constants
│   ├── features/                 # Feature-based modules
│   │   ├── auth/                 # Authentication screens
│   │   ├── jobs/                 # Job browsing and posting
│   │   ├── profile/              # User profiles and settings
│   │   ├── chat/                 # Messaging system
│   │   └── projects/             # Project management
│   └── shared/                   # Shared widgets and models
├── assets/                       # Images, icons, animations
└── pubspec.yaml                  # Dependencies and configuration
```

## 🚀 Getting Started

### Prerequisites
- PHP 8.2+
- Composer
- Node.js 16+
- MySQL/PostgreSQL
- Redis (for queues and caching)
- Flutter SDK 3.13+

### Backend Setup

1. **Install dependencies**
   ```bash
   cd backend
   composer install
   ```

2. **Environment configuration**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

3. **Database setup**
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

4. **Start the development server**
   ```bash
   php artisan serve
   ```

5. **Run in Agent Mode** (optional - for queue processing)
   ```bash
   # Start Redis
   sudo service redis-server start
   
   # Start Horizon (queue worker supervisor)
   php artisan horizon
   ```
   
   See [AGENT_MODE.md](AGENT_MODE.md) for detailed instructions on running in agent mode.

### Frontend Setup

1. **Install dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

## 🛠️ Technology Stack

### Backend
- **Framework**: Laravel 12.x
- **Authentication**: Laravel Sanctum
- **Real-time**: Laravel WebSockets / Pusher
- **Queue Management**: Laravel Horizon
- **Search**: Laravel Scout
- **Performance**: Laravel Octane
- **Database**: MySQL with Redis caching

### Frontend
- **Framework**: Flutter 3.13+
- **State Management**: Riverpod
- **Networking**: Dio HTTP client
- **Local Storage**: Hive database
- **Authentication**: Firebase Auth
- **Push Notifications**: Firebase Messaging
- **Video Calls**: Agora SDK
- **UI Components**: Material Design 3

### DevOps & Deployment
- **CI/CD**: GitHub Actions
- **Backend Hosting**: Shared hosting (Namecheap) compatible
- **Frontend**: Firebase Hosting (Web), App Store & Play Store
- **Monitoring**: Laravel Telescope, Firebase Analytics

## 📊 Database Schema

### Core Tables
- `users` - User profiles with role-based permissions
- `jobs` - Job postings with categories and requirements
- `proposals` - Freelancer proposals and bids
- `projects` - Active project management
- `categories` - Job categorization system
- `messages` - Real-time chat system
- `notifications` - User notification management

## 🎨 Design System

### Color Palette
- **Primary**: Bangladesh Green (#006A4E) - representing national identity
- **Secondary**: Vibrant Orange (#FF6B35) - for call-to-action elements
- **Accent**: Trust Blue (#2196F3) - for information and links
- **Status Colors**: Success, Error, Warning, Info variants

### Typography
- **Primary**: Inter font family for excellent readability
- **Bangla Support**: SolaimanLipi for Bengali text
- **Responsive**: Adaptive text scaling for different screen sizes

## 🔒 Security Features

- **Role-based permissions** with Spatie Laravel Permission
- **API rate limiting** to prevent abuse
- **CSRF protection** on all forms
- **SQL injection prevention** with Eloquent ORM
- **XSS protection** with input sanitization
- **File upload validation** with type and size restrictions
- **Two-factor authentication** for enhanced security

## 📱 Mobile App Features

- **Responsive layouts** for phone, tablet, and desktop
- **Offline mode** with local data caching
- **Push notifications** for real-time updates
- **File uploads** with progress tracking
- **Biometric authentication** (fingerprint/face ID)
- **Deep linking** for seamless navigation

## 🌐 Internationalization

- **Multi-language support**: English and Bengali
- **RTL support** for Arabic/Persian users
- **Currency localization** with BDT as default
- **Date/time formatting** based on user timezone
- **Number formatting** with local conventions

## 📈 Analytics & Monitoring

- **User behavior tracking** with Firebase Analytics
- **Performance monitoring** with Laravel Telescope
- **Error tracking** with Firebase Crashlytics
- **Custom metrics** for business insights
- **A/B testing** framework for feature optimization

## 🧪 Testing

### Backend Testing
```bash
php artisan test
```

### Frontend Testing
```bash
flutter test
```

## 🚀 Deployment to Namecheap (fix.com.bd)

### Quick Deployment
```bash
# 1. Prepare deployment package
./deploy_to_namecheap.sh

# 2. Upload deploy_package/* to your hosting via FTP
# 3. Follow QUICK_START_NAMECHEAP.md for setup
```

### Deployment Resources
- **[Quick Start Guide](QUICK_START_NAMECHEAP.md)** - 30-minute deployment
- **[Complete Guide](NAMECHEAP_DEPLOYMENT.md)** - Detailed instructions
- **[Deployment Checklist](DEPLOYMENT_CHECKLIST.md)** - Don't miss a step
- **[Scripts Documentation](DEPLOYMENT_SCRIPTS_README.md)** - All scripts explained

### Deployment Tools
- `deploy_to_namecheap.sh` - Create deployment package
- `backup_namecheap.sh` - Backup database and files
- `diagnose_server.sh` - Troubleshoot server issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions:
- **Email**: support@gig.com.bd
- **Website**: https://gig.com.bd
- **Documentation**: [API Docs](https://api.gig.com.bd/docs)

---

Built with ❤️ for the freelancing community in Bangladesh 🇧🇩
