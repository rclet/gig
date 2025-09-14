# Contributing to Gig Marketplace

Thank you for considering contributing to the Gig Marketplace platform! This document provides guidelines for contributing to the project.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what behavior you expected**
- **Include screenshots if possible**
- **Include your environment details** (OS, browser, versions, etc.)

### Suggesting Enhancements

Enhancement suggestions are also welcome. Please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Describe the current behavior and expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

1. **Fork the repository** and create your branch from `develop`
2. **Make your changes** following the coding standards below
3. **Add tests** for your changes if applicable
4. **Ensure all tests pass**
5. **Update documentation** if needed
6. **Create a pull request** with a clear title and description

#### Branch Naming Convention

- `feature/feature-name` - for new features
- `bugfix/bug-description` - for bug fixes
- `hotfix/critical-fix` - for critical production fixes
- `docs/documentation-update` - for documentation updates

#### Commit Message Convention

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): brief description

Detailed description if needed

- Additional notes
- Breaking changes
```

Examples:
- `feat(auth): add social login with Google`
- `fix(jobs): resolve search filter bug`
- `docs(readme): update installation instructions`

## Development Setup

### Backend (Laravel)

1. **Clone the repository**
   ```bash
   git clone https://github.com/rclet/gig.git
   cd gig/backend
   ```

2. **Install dependencies**
   ```bash
   composer install
   ```

3. **Setup environment**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Setup database**
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

5. **Run the development server**
   ```bash
   php artisan serve
   ```

### Frontend (Flutter)

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For mobile
   ```

## Coding Standards

### Backend (Laravel/PHP)

- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standards
- Use meaningful variable and function names
- Write comprehensive PHPDoc comments
- Follow Laravel conventions and best practices
- Use type hints and return types
- Write tests for new functionality

Example:
```php
<?php

/**
 * Create a new job posting.
 *
 * @param array $jobData The job data to create
 * @return Job The created job instance
 * @throws ValidationException If validation fails
 */
public function createJob(array $jobData): Job
{
    $validatedData = $this->validateJobData($jobData);
    
    return Job::create($validatedData);
}
```

### Frontend (Flutter/Dart)

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful widget and variable names
- Write comprehensive documentation comments
- Follow Flutter conventions and best practices
- Use proper state management patterns
- Write tests for widgets and logic

Example:
```dart
/// A widget that displays a job card with basic information.
///
/// This widget shows the job title, company, budget, and other
/// essential details in a card format suitable for list views.
class JobCard extends StatelessWidget {
  /// Creates a job card widget.
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  /// The job data to display.
  final Job job;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Testing

### Backend Testing

Run the test suite:
```bash
cd backend
php artisan test
```

Write tests for:
- API endpoints
- Models and relationships
- Services and business logic
- Database operations

### Frontend Testing

Run the test suite:
```bash
cd frontend
flutter test
```

Write tests for:
- Widget functionality
- State management
- API integration
- User interactions

## Documentation

- Update the README.md if needed
- Add inline code documentation
- Update API documentation
- Include examples for new features

## Performance Considerations

### Backend
- Use database indexing appropriately
- Implement caching where beneficial
- Optimize database queries
- Use queues for heavy operations

### Frontend
- Optimize widget rebuilds
- Use proper list view builders for large datasets
- Implement image caching
- Minimize network requests

## Security Guidelines

- Never commit sensitive information (API keys, passwords)
- Validate all user inputs
- Use proper authentication and authorization
- Follow OWASP security guidelines
- Implement rate limiting for API endpoints

## Questions?

If you have questions about contributing, please:

1. Check the existing documentation
2. Search through existing issues
3. Create a new issue with the "question" label
4. Contact the maintainers at dev@gig.com.bd

Thank you for contributing to Gig Marketplace! 🚀