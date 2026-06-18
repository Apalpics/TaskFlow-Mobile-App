# Team Module Contributions

This folder documents the individual module contributions for **TaskFlow: Smart Academic Task and Collaboration Management System**.

The purpose of this folder is to provide clear teamwork evidence for INFO 4335 Mobile Application Development. The project was completed as a Flutter/Firebase group application, and each member was assigned a specific module. The contribution files explain each member's responsibility, the feature logic, the relevant code paths, and the way their module connects to the final integrated app.

## Why this folder exists

The team had limited GitHub collaboration experience, and the project deadline was close. To avoid merge conflicts, broken code, and accidental overwriting of the working Flutter app, the team used this `docs/contributions/` folder to collect module contribution files in one place.

Each member prepared or documented their assigned module here. The final integrator reviewed the module contributions, corrected incomplete parts, connected the modules to Firebase/Firestore where needed, tested the full app, and pushed the stable final source code to GitHub.

This method does **not** mean the module files are separate apps. They are contribution evidence and explanation files that support the final Flutter implementation under the `lib/` folder.

## Assessment alignment

The final project requires a functional Flutter app, GitHub source code, a final report, and a 5-minute demo video where each member presents their own contribution clearly. The coding requirements include Flutter widgets/layouts, forms and validation, navigation, state management, pub.dev packages, Firebase integration, UI/UX quality, clean code structure, and teamwork evidence.

## Final team responsibility table

| Member | Matric Number | Assigned Module | Main Contribution Evidence |
|---|---:|---|---|
| Abdulgafar Abdullahi Ibrahim | 2311279 | Firebase Setup, Authentication, User Profile, Final Integration | Firebase initialization, login/register, Firestore `users` collection, profile screen, logout, app routing, bottom navigation integration, final testing and GitHub push |
| Adil Emadeldin Abdelkarim | 2320799 | Dashboard UI, Theme Design, Navigation | Dashboard layout ideas, summary cards, deadline cards, app theme consistency, navigation structure explanation |
| Newal Yeshak Abduljalil | 2315376 | Assignment Management Module | Add assignment form, assignment fields, validation logic, assignment card ideas, Firestore `assignments` structure |
| Marwa Mustafa Ali | 2110126 | Group Project Management Module | Group task schema, project/task/assigned-to/status fields, group task card idea, Firestore `groupTasks` structure |
| Abubakar Abdulsalam | 2328587 | File Metadata and Reminder System, Report Compilation Support | File metadata idea, `file_picker` usage, Firestore `files` structure, reminders classification, report compilation support with Marwa and Adil |

## Final implemented Flutter code paths

The final app code is located mainly under the `lib/` folder:

```text
lib/main.dart
lib/firebase_options.dart
lib/core/routes/app_routes.dart
lib/core/theme/app_theme.dart
lib/features/auth/screens/login_screen.dart
lib/features/auth/screens/register_screen.dart
lib/features/dashboard/screens/main_navigation_screen.dart
lib/features/dashboard/screens/dashboard_screen.dart
lib/features/assignments/screens/assignments_screen.dart
lib/features/assignments/screens/add_assignment_screen.dart
lib/features/assignments/widgets/assignment_card.dart
lib/features/progress/screens/progress_screen.dart
lib/features/groups/screens/group_tasks_screen.dart
lib/features/files/screens/files_screen.dart
lib/features/files/screens/reminders_screen.dart
lib/features/profile/screens/profile_screen.dart
```

## Contribution files in this folder

| File | Contributor | Purpose |
|---|---|---|
| `abdulgafar_firebase_auth_profile_integration_code.md` | Abdulgafar Abdullahi Ibrahim | Explains Firebase setup, Authentication, Firestore users profile, logout, app routing, and final integration code |
| `adil_dashboard_navigation_code.md` | Adil Emadeldin Abdelkarim | Explains dashboard UI, summary cards, theme design, and navigation ideas |
| `newal_assignment_module_code.md` | Newal Yeshak Abduljalil | Explains assignment management form, fields, card design, validation, and Firestore assignment structure |
| `marwa_group_project_module_code.md` | Marwa Mustafa Ali | Explains group project management, group task fields, card layout, and Firestore groupTasks structure |
| `abubakar_file_reminder_module_code.md` | Abubakar Abdulsalam | Explains file metadata handling, reminder classification, file cards, and Firestore files structure |

##  GitHub/teamwork workflow note

The group divided work by module from the start. Because not all members were comfortable editing the Flutter project directly through GitHub branches and pull requests, module documentation and code ideas were collected in this folder first.

The final integration workflow was:

1. Each member worked on or documented their assigned module.
2. The module files were placed in `docs/contributions/` as contribution evidence.
3. Abdulgafar handled final Flutter/Firebase setup and integration to keep the app stable.
4. The final app code was tested with `flutter analyze`.
5. The final app was pushed to GitHub for lecturer inspection.
6. Each member prepared an individual video/report explanation for their own module.

## Firebase services and data collections

The app uses:

- **Firebase Authentication** for email/password registration and login.
- **Cloud Firestore** for storing user profiles, assignments, group tasks, and file metadata.

Final Firestore collections:

| Collection | Purpose | Main Fields |
|---|---|---|
| `users` | Stores registered user profile data | `uid`, `name`, `email`, `profileImage`, `createdAt`, `updatedAt` |
| `assignments` | Stores academic assignments | `title`, `courseName`, `description`, `deadline`, `priority`, `status`, `createdBy`, `createdAt` |
| `groupTasks` | Stores group project tasks | `projectName`, `taskTitle`, `assignedTo`, `deadline`, `status`, `createdBy`, `createdAt` |
| `files` | Stores file metadata records | `fileName`, `fileType`, `assignmentTitle`, `note`, `uploadedBy`, `uploadedAt` |

## Firebase Storage limitation

Firebase Storage was not used for real binary file upload because the Firebase project required a pricing plan upgrade for Storage. For this reason, the file module was implemented as a **metadata-only file management module** using Cloud Firestore. This limitation is documented clearly and can be improved in the future by enabling Firebase Storage after upgrading the Firebase project plan.

## Report and video responsibility note

Every member should explain only their own contribution in their individual video/report. The report compilation can be coordinated by Abubakar with support from Marwa and Adil, but each member must still provide their own module explanation and understand their own code.

Suggested report coordination:

- Abdulgafar: Firebase setup, Authentication, User Profile, final integration, Firebase evidence, testing evidence.
- Adil: Dashboard UI, theme design, navigation, UI/UX explanation.
- Newal: Assignment management, add assignment form, assignment list/cards, Firestore assignments.
- Marwa: Group project management, group task form/cards, Firestore groupTasks.
- Abubakar: Files metadata, reminders, Storage limitation, report compilation and formatting support.

## Final note

This folder should be kept in the GitHub repository because it supports teamwork evidence, module ownership, report writing, and individual demo preparation. The working Flutter code is under `lib/`; this folder explains how the team divided and documented the work.
