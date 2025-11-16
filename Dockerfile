# Flutter + Android SDK image (Linux)
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Workdir inside container
WORKDIR /app

# Install any extra packages
RUN apt-get update && apt-get install -y libsqlite3-dev

# Use Docker layer caching: copy pubspec first
COPY pubspec.yaml pubspec.lock ./ 
RUN flutter pub get

# Now copy the rest of the source
COPY . .

# Make sure Android is enabled (usually already true)
RUN flutter config --enable-web && flutter doctor -v

# ---- Build commands ----
# Release APK
RUN flutter build apk --release

# Play Store bundle
RUN flutter build appbundle --release

# Default command: open a shell so you can inspect artifacts if you run interactively
CMD ["bash"]