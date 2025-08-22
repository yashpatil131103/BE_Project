📌 Task Management System

A Task Management System built using Flutter and Firebase as part of a final-year major project. The system is designed to streamline project and task handling within an organization by providing a structured hierarchy and role-based functionalities.

🚀 Features

🔑 User Authentication (Firebase Authentication)

👨‍💼 Role-Based Access Control

Manager – Creates and assigns projects to Team Leads

Team Lead (TL) – Assigns tasks to employees and monitors progress

Employee – Views assigned tasks and updates task status

📊 Task Progress Tracking (In-progress, Completed, Pending)

🔄 Real-time Updates using Firebase Firestore

📱 Cross-platform – Works on both Android & iOS

🛠️ Scalable Database – Firebase for real-time data sync

🔔 Notifications/Reminders (optional with Firebase Cloud Messaging)

🏗️ System Hierarchy

Manager → Team Lead (TL) → Employee

Manager

Creates projects

Assigns project to a Team Lead

Monitors overall progress

Team Lead

Receives project from Manager

Creates tasks under the project

Assigns tasks to employees

Tracks team performance

Employee

Views assigned tasks

Updates task progress

Marks completion of tasks

⚙️ Tech Stack

Frontend: Flutter (Dart)

Backend & Database: Firebase Firestore

Authentication: Firebase Auth

Cloud Functions (optional): For automation and notifications

State Management: Provider
