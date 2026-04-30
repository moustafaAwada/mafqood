# Mafqood

> **A comprehensive Missing and Found ecosystem bridging the gap between lost items/people and their safe return.**

---

## ✨ Key Features

*   **Real-time Feed:** Discover and share critical posts instantly with our continuously updating feed.
*   **SignalR Chat:** Seamless, instantaneous, and secure peer-to-peer messaging for coordinating recoveries, backed by robust offline queuing and reconnect logic.
*   **Smart Location Tagging:** Geolocation services ensuring accurate pin-drops for where items or individuals were last seen.
*   **AI-Matching Potential:** (Upcoming) Intelligent backend matching to automatically pair "Lost" reports with corresponding "Found" items using image recognition and metadata.

---

## 🏗️ Technical Architecture

Mafqood is built upon strict adherence to **Uncle Bob's Clean Architecture**, separating concerns into distinct layers:

1.  **Domain:** Core business logic, entities, and abstract repository contracts.
2.  **Data:** Concrete repository implementations, API data sources, models, and mappers.
3.  **Presentation:** Flutter UI widgets, screens, and Bloc/Cubit state management.

### The 6-Step Integration Pipeline
Every feature in Mafqood strictly follows this pipeline to ensure quality and scalability:
1.  **Define Entities & Models:** Establishing the shape of the data.
2.  **Abstract Repositories (Domain):** Defining contracts.
3.  **Concrete Repositories (Data):** Implementing API calls and data mapping.
4.  **Use Cases:** Encapsulating specific business actions.
5.  **State Management (Bloc/Cubit):** Connecting use cases to reactive state.
6.  **UI Integration:** Building the presentation layer and wiring it up.

---

## 🛠️ Tech Stack

| Technology | Implementation |
| :--- | :--- |
| **Frontend** | Flutter & Dart |
| **State Management** | Bloc / Cubit |
| **Networking** | Dio (with custom Interceptors) |
| **Real-time** | SignalR |
| **Dependency Injection** | Get_it |
| **Backend** | .NET Core 8 Web API |

---

## 📂 Project Organization

```text
lib/
├── core/
│   ├── network/       # Dio clients, API interceptors, endpoints
│   ├── error/         # Failure models, exception handling
│   ├── di/            # Get_it dependency injection setup
│   ├── utils/         # Helper functions, constants, styling
│   └── shared/        # Reusable global widgets
├── features/
│   ├── auth/          # Authentication, Registration
│   ├── posts/         # Feed, Post Creation, Form Data
│   ├── chat/          # SignalR Chat, Conversational UI
│   ├── home/          # Main Navigation
│   └── ...            # Other feature modules
└── main.dart          # App entry point
```

Each feature module (e.g., `features/chat/`) internally mirrors the Clean Architecture layers:
```text
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── screens/
    └── widgets/
```

---

## 🚀 Installation Guide

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/mafqood.git
    cd mafqood
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure API Base URL:**
    *   Locate the network configuration file (e.g., `lib/core/network/api_constants.dart` or your `.env` configuration).
    *   Update the `baseUrl` to point to the correct `.NET Core 8 Web API` endpoint (local or production).

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🗺️ Current Roadmap

### ✅ Completed Milestones
*   **Authentication:** Secure login, registration, and token management.
*   **Posts & Feed Integration:** Full CRUD for missing/found posts with multipart form data (images) and pagination.
*   **Chat Bridge:** Real-time bi-directional messaging with read receipts and offline queueing.

### ⏳ Future Goals
*   **Push Notifications:** System-wide alerts for matches and messages.
*   **AI Matching:** Automated intelligent matching algorithm to connect lost and found posts.
*   **Advanced Filtering:** Granular search by category, date, and geographic radius.

---

## 👨‍💻 Developer

**Mohamed Asem Yaser**
*   [LinkedIn](#) <!-- Add your LinkedIn URL here -->
*   [GitHub](#) <!-- Add your GitHub URL here -->
*   [Portfolio](#) <!-- Add your Portfolio URL here -->
*   Email: [your.email@example.com](mailto:your.email@example.com)
