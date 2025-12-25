LMS Flutter Project – Friend LMS (Learning Management System)

📚 Introduction
This is a cross-platform Learning Management System (LMS) built using Flutter, supporting both web and mobile platforms. The application provides an intuitive platform for students to share educational resources, discover opportunities, and collaborate effectively.

✨ Key Features

User Authentication: Secure login/signup using Firebase Auth

Notes Management: Upload, view, search, and filter study notes

Opportunities Board: Discover internships, jobs, and research opportunities

Modern UI/UX: Clean, responsive design with smooth animations

Cross-Platform: Works seamlessly on web, iOS, and Android

Docker Support: Containerized deployment for consistent environments

🎯 Project Goals

Demonstrate professional Flutter development practices

Implement complete Git workflow with branching and merging

Showcase Docker containerization for Flutter web apps

Provide a production-ready educational platform

🏗️ Project Structure
lms/
├── lib/                                # Flutter source code
│   ├── screens/
│   │   ├── home_screen.dart            # Main dashboard
│   │   ├── notes_screen.dart           # Notes management
│   │   ├── upload_note.dart            # Uploading Notes
│   │   ├── opportunities_screen.dart   # Opportunities management
│   │   ├── add_opportunity_screen.dart # Uploading opportunities
│   │   ├── profile_screen.dart         # Profile management
│   │   ├── auth_screen.dart            # Authentication
│   │   └── pdf_viewer_screen.dart      # Managing pdf view in browser
│   └── main.dart                        # App entry point
├── assets/                              # Static assets
├── pubspec.yaml                         # Dependencies
├── Dockerfile                           # Docker configuration
├── firebase.json                        # Firebase hosting config
└── README.md                            # Documentation

🚀 Commands Used
📱 Flutter Development
# Initialize Flutter project
flutter create lms

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for web (release)
flutter build web --release

# Run tests
flutter test

🐳 Docker Commands
# Build Docker image
docker build -t lms-flutter .

# Run container
docker run -p 8080:8080 lms-flutter

# Check running containers
docker ps

# View logs
docker logs <container_id>

🔥 Firebase Deployment
# Initialize Firebase Hosting
firebase init hosting

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Open deployed site
firebase open hosting:site

🔧 Git Workflow – Polished Version
1. Fork the Original Repository
# Navigate to the original repo on GitHub and click "Fork"
# Creates a copy under your GitHub account

2. Clone Your Fork
git clone https://github.com/Anjali11s/lms
cd lms

3. Set Up Remote Configuration
# Check current remote
git remote -v
# origin  https://github.com/Anjali11s/lms.git (fetch/push)

# Add upstream (original repo) to sync future updates
git remote add upstream https://github.com/Gautamsam3/lms

4. Work on Main Branch First
git checkout main
# Made core changes: added screens, Firebase integration, notes & opportunities features
git add .
git commit -m "📦 Updated LMS with main screens, authentication, and Firebase integration"
git push origin main

5. Create & Work on Feature Branches
# UI Improvements
git checkout -b ui-improvements
# Made UI changes to home_screen.dart
git add .
git commit -m "✨ Redesign home screen with modern UI elements and animations"
git push origin ui-improvements

# Bugfix – Login Screen
git checkout -b bugfix-login
# Fixed auth screen layout inconsistencies
git add .
git commit -m "🐛 Fixed auth screen layout inconsistency"
git push origin bugfix-login

# Notes Feature Enhancements
git checkout -b feature-notes-enhancement
# Enhanced notes screen UI with improved search
git add .
git commit -m "🎨 Enhanced notes screen UI with modern design and search improvements"
git push origin feature-notes-enhancement

# Docker Experiment
git checkout -b experiment-docker
# Added Dockerfile for Flutter web deployment
git add Dockerfile
git commit -m "🐳 Add Docker setup for Flutter web"
git push origin experiment-docker

6. Merge Feature Branches into Main
git checkout main
git merge ui-improvements
git merge bugfix-login
git merge feature-notes-enhancement
git merge experiment-docker
git push origin main

7. Handle Merge Conflicts – Conflict Demo
# Step 1: Create conflict-demo branch
git checkout -b conflict-demo
# Made intentional conflicting changes
git add .
git commit -m "🔀 Create intentional conflict for demo"
git push origin conflict-demo

# Step 2: Modify same file in main branch
git checkout main
# Made different changes
git add .
git commit -m "Update home screen content in main branch"
git push origin main

# Step 3: Merge conflict-demo into main (creates conflict)
git merge conflict-demo
# CONFLICT detected in home_screen.dart

# Step 4: Resolve Conflict
git status          # Check files with conflict
git diff            # See conflicting lines
# Edit home_screen.dart manually to resolve conflicts
git add home_screen.dart
git commit -m "✅ Resolved merge conflict between main and conflict-demo"
git push origin main

8. Create Pull Requests

Navigate to GitHub → Pull Requests → New Pull Request

Create PRs from:

ui-improvements → main

bugfix-login → main

feature-notes-enhancement → main

experiment-docker → main

📸 Screenshots

Docker Deployment: Flutter web running in Docker



Web Deployment: Live deployment on Firebase Hosting 


GitHub Branches: Multiple branches showing Git workflow


🧩 Challenges & Solutions

Merge Conflict Resolution: Manual resolution of intentional conflicts in home_screen.dart

Docker Setup: Multi-stage Dockerfile for Flutter build & Nginx serving

UI Consistency: Reusable components, consistent padding, standard card layouts

Search Implementation: Combined filtering with debouncing

Responsive Design: MediaQuery, LayoutBuilder, responsive widgets

📈 Git Workflow Implementation

Branch Strategy

main: Production-ready stable code

ui-improvements: Visual enhancements & redesigns

bugfix-*: Individual bug fixes

feature-*: New feature development

experiment-*: Experimental changes

🏆 Conclusion

Achievements

Complete Flutter LMS with authentication, notes management, and opportunities board

Professional Git workflow with branching, merging, and conflict resolution

Docker containerization for Flutter web

Live deployment on Firebase Hosting

Modern, cross-platform UI/UX

Technical Skills Demonstrated

Flutter Development: State management, navigation, responsive design

Firebase Integration: Authentication & hosting

Docker: Containerization & deployment

Git: Version control & collaboration

UI/UX Design: Consistent modern interface

Future Enhancements

Real-time Chat

Video Lectures

Assignment Submission

Push Notifications


Learning Outcomes

End-to-end Flutter application development

Professional software engineering practices

Collaborative Git workflow management

Containerized deployment strategies

Production-grade application design principles

Contributors

Project Lead: [Anjali Singh]

Version Control: Git & GitHub

Hosting: Firebase

Containerization: Docker

Framework: Flutter

License

Developed for educational purposes as part of academic coursework

Last Updated: December 2025

Flutter Version: 3.16.0

Status: ✅ Production Ready

Live Demo: [https://lms-web-5096a.web.app/]

Repository: [https://github.com/Anjali11s/lms]
