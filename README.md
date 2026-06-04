# TaskFlow

## 1. Group Members
| Name                         | Matric Number | Assigned Module                              |
| ---------------------------- | ------------- | -------------------------------------------- |
| Abdulgafar Abdullahi Ibrahim | 2311279       | Firebase Setup, Authentication, User Profile |
| Adil Emadeldin Abdelkarim    | 2320799       | Dashboard UI, Theme Design, Navigation       |
| Newal Yeshak Abduljalil      | 2315376       | Assignment Management Module                 |
| Marwa Mustafa Ali            | 2110126       | Group Project Management Module              |
| Abubakar Abdulsalam          | 2328587       | File Uploads and Reminder System             |

## 2. Project Title
TaskFlow: Smart Academic Task and Collaboration Management System

## 3. Introduction
University students often face difficulties managing multiple assignments, tracking deadlines, organizing academic tasks, and coordinating group projects. Many students rely on separate tools such as messaging applications, calendars, and note-taking platforms, which can lead to missed deadlines, poor task visibility, and inefficient collaboration.

TaskFlow is a mobile application developed to provide students with a centralized platform for managing academic responsibilities. The application enables students to create and manage assignments, monitor progress, collaborate on group projects, upload important files, and receive reminders for upcoming deadlines.

By combining these features into a single mobile application, TaskFlow aims to improve productivity, organization, and collaboration among students while providing a simple and user-friendly experience.
## 4. Objectives
1. To provide a centralized platform for managing academic assignments and tasks.

2. To help students monitor and track assignment deadlines effectively.

3. To improve productivity through task progress tracking and reminder features.

4. To support collaboration and communication for group projects.

5. To enable students to store and access assignment-related files in one place.

6. To provide a simple, efficient, and user-friendly mobile application experience.
## 5. Target Users
### Primary Users

University and college students who need a structured way to manage assignments, deadlines, academic files, and group projects.

### Secondary Users

Student groups working on collaborative assignments and projects that require task tracking and progress monitoring.
## 6. Features & Functionalities

### Authentication Module

* User registration and login using Firebase Authentication.
* Secure access to personal assignment data.
* Logout functionality.

### Assignment Management Module

* Create new assignments.
* Edit assignment details.
* Delete assignments.
* View assignment information.
* Mark assignments as completed.

### Deadline Tracking Module

* Display upcoming deadlines.
* Highlight overdue assignments.
* Organize assignments by due date and priority level.

### Progress Tracking Module

* Monitor assignment completion status.
* Visual progress indicators.
* Track completed and pending tasks.

### Group Collaboration Module

* Manage group project tasks.
* Assign responsibilities to group members.
* Monitor group task progress.

### File Management Module

* Upload assignment-related files.
* Store and access academic resources.
* Organize files by assignment or project.

### Reminder & Notification Module

* Receive reminders for upcoming deadlines.
* Notification preferences through user settings.

### User Profile Module

* View and update profile information.
* Manage account settings.
* Logout functionality.

## 7. UI Mock-ups


The following key screens will be included in the TaskFlow mobile application:

1. Login Screen  
2. Dashboard Screen  
3. Add Assignment Screen  
4. Assignment Details Screen  
5. Group Collaboration Screen  
6. Progress Tracking Screen  
7. Profile Screen  
8. Notifications Screen  

UI mock-ups are designed using Figma and follow a clean, student-friendly interface with consistent colors and simple navigation.
## 8. Architecture / Technical Design

TaskFlow is developed using Flutter with a modular architecture approach.

### Frontend
- Flutter Framework
- Material Design 3 UI components
- Responsive layouts using Row, Column, ListView, and Stack
- Named route navigation

### Backend Services (Firebase)
- Firebase Authentication for user login and registration
- Cloud Firestore for real-time database storage
- Firebase Storage for file uploads (assignments and images)
- Firebase Cloud Messaging for notifications (optional)

### State Management
The app initially uses Flutter setState for simple state updates. As the application scales, Provider will be used to manage shared state across modules.

### App Structure (Modules)
- Authentication Module
- Dashboard Module
- Assignment Management Module
- Group Collaboration Module
- File Management Module
- Notification Module
- User Profile Module
## 9. Data Model

### Users Collection
users
- uid
- name
- email
- profileImage

### Assignments Collection
assignments
- assignmentId
- title
- description
- deadline
- priority
- status (pending / in progress / completed)
- createdBy

### Groups Collection
groups
- groupId
- groupName
- members (array of user IDs)
- tasks

### Files Collection
files
- fileId
- fileName
- uploadedBy
- assignmentId
- fileUrl
- uploadedAt

## 10. Flowchart / Sequence Diagram

Flowcharts and sequence diagrams will be created using Mermaid Chart.

The diagrams will include:
- User authentication flow
- Assignment creation and management flow
- Group collaboration workflow
- File upload process
- Notification and reminder flow

## 11. Project Timeline and Milestones

| Date / Phase    | Planned Activity                                                                | Expected Output                                                                                   |
| --------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 5 June 2026     | Submit proposal README through GitHub repository URL                            | Proposal submitted with project scope, team roles, mockups, data model, flowchart, and references |
| 6–7 June 2026   | Set up Flutter project, GitHub structure, and Firebase project                  | Flutter project created, Firebase connected, basic folder structure prepared                      |
| 8–10 June 2026  | Develop Authentication, User Profile, Dashboard, and Navigation modules         | Login, registration, profile page, dashboard, and bottom navigation working                       |
| 11–13 June 2026 | Develop Assignment Management, Deadline Tracking, and Progress Tracking modules | Add/edit/delete assignments, assignment list, deadline indicators, and progress screen working    |
| 14–15 June 2026 | Develop Group Project Management, File Upload, and Reminder modules             | Group tasks, Firebase Storage file upload, due today/due tomorrow/overdue indicators working      |
| 16–17 June 2026 | Testing, debugging, UI polishing, and Firebase data checking                    | Stable app with fewer errors, improved UI, tested CRUD operations                                 |
| 18 June 2026    | Final code submission through GitHub and iTa’Leem                               | Complete source code submitted                                                                    |
| 19 June 2026    | Final demo video presentation                                                   | 5-minute demo video showing major features and individual contributions                           |

## 12. References

Flutter Docs: https://docs.flutter.dev

Firebase Docs: https://firebase.google.com/docs

Material Design 3: https://m3.material.io

Flutter Packages: https://pub.dev

Mermaid Diagrams: https://mermaid.js.org

Figma UI Mock-ups: https://www.figma.com/file/example_mockup_hash

GitHub Markdown Guide: https://docs.github.com/en/get-started/writing-on-github





