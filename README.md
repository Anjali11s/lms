# Friend LMS – Flutter Learning Management System

## Project Overview
Friend LMS is a cross-platform Learning Management System developed using Flutter.
It allows students to upload notes, explore opportunities, and access resources through a clean and responsive interface.

This project was created to demonstrate:
- Flutter application development
- Git & GitHub workflow
- Branching, merging, and conflict resolution
- Docker deployment for Flutter Web
- Firebase Hosting deployment

## Key Features
- User authentication using Firebase Auth
- Notes upload, view, and search
- Opportunities board
- Responsive and modern UI
- Supports Web, Android, and iOS
- Dockerized Flutter Web deployment
- Live deployment using Firebase Hosting

## Project Structure
```text
lms/
├── lib/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── notes_screen.dart
│   │   ├── upload_note.dart
│   │   ├── opportunities_screen.dart
│   │   ├── add_opportunity_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── auth_screen.dart
│   │   └── pdf_viewer_screen.dart
│   └── main.dart
├── assets/
├── pubspec.yaml
├── Dockerfile
├── firebase.json
└── README.md
Flutter Commands Used
bash
Copy code
flutter pub get
flutter run -d chrome
flutter build web --release
Docker Commands Used
bash
Copy code
docker build -t lms-flutter .
docker run -d -p 8080:80 lms-flutter
docker ps
docker logs <container_id>
Firebase Hosting Commands
bash
Copy code
firebase init hosting
firebase deploy --only hosting
Live Website:
https://lms-web-5096a.web.app/

Git Workflow
Fork & Clone
bash
Copy code
git clone https://github.com/Anjali11s/lms.git
cd lms
Branches Used
main

ui-improvements

bugfix-login

feature-notes-enhancement

experiment-docker

conflict-demo

Git Commands Used
bash
Copy code
git add .
git commit -m "commit message"
git push origin branch_name
git merge branch_name
git pull origin main
Merge Conflict Handling
Merge conflict created intentionally

Conflict resolved manually

Final merge committed successfully

Learning Outcomes
Flutter web & mobile development

Git and GitHub version control

Branching and merging strategies

Docker usage for Flutter Web

Firebase hosting deployment

Author
Anjali Singh
Department of Computer Science & Engineering

Project Links
GitHub Repository:
https://github.com/Anjali11s/lms

Live Demo:
https://lms-web-5096a.web.app/

License
This project is developed for educational purposes as part of academic coursework.

Last Updated: December 2025
Status: ✅ Completed