FROM ghcr.io/cirruslabs/flutter:3.24.5

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Analyze the code
RUN flutter analyze

# Try to build for web
RUN flutter build web --release