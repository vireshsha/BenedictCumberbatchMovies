# 🎬 Benedict Cumberbatch Movies

An iOS app showcasing a list of **Benedict Cumberbatch** movies using a hybrid **UIKit + SwiftUI + Coordinator** architecture.  
This project demonstrates modern app structure, clean navigation management, and testable MVVM logic using native Apple frameworks.

---

## ⚙️ Setup Instructions

1. **Clone or unzip** the repository:
   ```bash
   git clone https://github.com/vireshsha/BenedictCumberbatchMovies.git
   cd BenedictCumberbatchMovies
   ```

2. **Open** the project in **Xcode 15 or later**  
   File: `BenedictCumberbatchMovies.xcodeproj`

3. **Configure the TMDB API Key**  
   Create a `Secrets.xcconfig` file (or set an environment variable):
   ```
   TMDB_API_KEY = your_api_key_here
   ```
   Get your API key from [The Movie Database (TMDB)](https://developers.themoviedb.org/3/getting-started/introduction).

4. **Run the app**
   - Select a simulator (e.g., iPhone 15 Pro)
   - Press **⌘R** to build and run

5. **Run unit tests**
   ```
   ⌘U
   ```
   or *Product → Test* from the Xcode menu.

---

## 🧩 Architecture Overview

This app follows a **Coordinator + MVVM** architecture to separate navigation logic from UI and business logic.

### 🧭 Coordinator Pattern
The **Coordinator pattern** is responsible for managing screen flow between UIKit and SwiftUI components:
- The **AppCoordinator** creates and owns the root navigation controller.
- It handles presenting the **HomeViewController** (UIKit) and pushing the **MovieDetailView** (SwiftUI) wrapped in a `UIHostingController`.
- This ensures navigation logic is **centralized, reusable, and testable**, keeping ViewControllers lightweight.

**Why use a Coordinator?**
- Removes navigation logic from ViewControllers.
- Simplifies unit testing and mocking.
- Scales better as navigation complexity increases.
- Decouples UIKit and SwiftUI layers safely.

### 🏗 MVVM Structure
| Layer | Responsibility |
|--------|----------------|
| **Model** | Defines `Movie` data from TMDB. |
| **ViewModel** | Holds business logic and publishes UI state. |
| **View** | UIKit renders the list, SwiftUI renders detail. |
| **Coordinator** | Manages transitions and dependency injection. |

---

## 🧱 UIKit vs SwiftUI: Design Decisions

| Technology | Screen | Reason |
|-------------|---------|--------|
| **UIKit** | Movie List | Demonstrates legacy support and Auto Layout control. |
| **SwiftUI** | Movie Detail | Showcases modern declarative UI and Combine binding. |
| **Coordinator (Bridge)** | Navigation | Manages transition between UIKit and SwiftUI screens. |

This hybrid design models how new SwiftUI modules can integrate into legacy UIKit codebases seamlessly.

---

## 🧰 Libraries & Frameworks Used

| Library / Framework | Purpose |
|----------------------|----------|
| **UIKit** | Movie list + navigation container |
| **SwiftUI** | Movie detail screen |
| **Combine** | Data binding between ViewModel and SwiftUI |
| **Foundation / URLSession** | Networking and JSON decoding |
| **NSCache** | Efficient in-memory image caching |
| **Swift Concurrency (async/await)** | Simplified async networking and image loading |

> 💡 No third-party dependencies — only Apple-native APIs.

---

## 🚀 Potential Improvements (With More Time)

- Add **search, sorting, and pagination** in the movie list.
- Implement **error states and placeholders** in AsyncImageView.
- Introduce **Dependency Injection** for testing MovieService.
- Add **snapshot/UI tests** for SwiftUI screens.
- Persist **favorites** using Core Data or SwiftData.
- Improve accessibility and dynamic type scaling.

---

## 🧠 Challenges Encountered

1. **UIKit ↔ SwiftUI Integration**  
   Ensuring clean data flow and navigation between the two frameworks.  
   ✅ Solved via the **Coordinator** using dependency injection of ViewModels.

2. **Memory Crash During Tests**  
   `@Published` teardown ran on a background thread causing a deallocation crash.  
   ✅ Fixed by marking `MovieDetailViewModel` as `@MainActor` and cancelling any active async tasks.

3. **Image Loading Concurrency**  
   Prevented race conditions using an `actor`-based `ImageLoader` with thread-safe caching.

4. **Testing Combine Publishers**  
   Used `XCTestExpectation` with Combine to verify emissions from `@Published` properties.

---

## 🧾 Summary

This project demonstrates:
- ✅ Clean **Coordinator + MVVM** architecture  
- ✅ Safe **UIKit–SwiftUI** integration  
- ✅ Reactive UI updates via Combine  
- ✅ Thread-safe async image loading  
- ✅ Thorough **unit test coverage** for ViewModels  

---

## 👤 Author

**Viresh Kumar Sharma**  
📧 vireshsha@gmail.com
💼 [LinkedIn](https://www.linkedin.com/in/viresh-kumar-sharma-b1351427) 
• 🧑‍💻 [GitHub](https://github.com/vireshsha)
