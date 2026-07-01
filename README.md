# SAFARLINK: Digital Inter-City Car Booking System 🚗✨

Safarlink is a cross-platform mobile application developed as our Final Year Capstone Project (FYP) for the Bachelor of Science in Software Engineering (BSSE) program at the University of Okara[cite: 1]. The system is designed to digitalize and decentralize the traditional inter-city transport "Adda" networks in Pakistan, introducing algorithmic fare calculations and peer-to-peer trust networks[cite: 1].

## 👥 Project Team Members
* **Khurshid Ahmad** (F22-BSSE-1046) - Lead Mobile Application Developer[cite: 1]
* **Sehrish Kanwal** (F22-BSSE-1018) - Software Requirements & Documentation Specialist[cite: 1]
* **Samreen Akhtar** (F22-BSSE-1028) - Quality Assurance & Architecture Engineer[cite: 1]

## 🎓 Project Advisor
* **Sir Muhammad Javed** (Manager Projects, Faculty of Computer Science, University of Okara)[cite: 1]

## 🛠️ Technical Architecture & Stack
* **Frontend Framework:** Flutter SDK (Dart)[cite: 1]
* **State Management & Architecture:** GetX Ecosystem (MVC Pattern Layout)[cite: 1]
* **Backend Services (BaaS):** Google Cloud Platform via Firebase (Firestore NoSQL, Authentication, Storage, FCM Push Alerts)[cite: 1]
* **Routing Network Engine:** Open-Source Routing Machine (OSRM) REST API[cite: 1]

## 🚀 Key Functional Modules Engineered
* **Smart Dynamic Pricing Engine:** Computes passenger fares in real-time based on live OSRM road distance vectors combined with custom driver metrics (mileage, fuel pricing, and net margins)[cite: 1].
* **Advanced Driver Trip Management:** Real-time collection stream parsing that splits active rides seamlessly into Active (Today's) or Upcoming sub-tabs with runtime transit lifecycle controls (`Start` / `End` trip).
* **Post-Confirmation P2P Token System:** An interactive glassmorphic transaction model allowing passengers to declare manual EasyPaisa/JazzCash advance receipts that sync instantly to the driver dashboard.
* **Reason-Enforced Cancellation Interceptor:** Protects marketplace trust by mandating clear reasoning drop-downs coupled with automated dial-intent prompts before mutation execution.

---
*Developed by Group ID: FALL-22-BSSE-8M | Session 2022-2026 | Faculty of Computer Science, University of Okara.*[cite: 1]
