# App Architecture
This repository follows an adaptation of Clean Architecture, largely inspired by [this tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
Clean Architecture separates the software into layers with defined responsibilities.
In this project we work with 3 main layers: presentation, business logic, and data.
Each layer covers a specific responsibility and follows the constraints described [below](#clean-folders).


## Folder Structure of the App
- lib
  - config
    - routes
    - theme
  - core
    - constants
    - firebase
    - resources
    - usecase
  - features
    - {feature}
      - data
        - data_sources
        - models
        - repository
      - domain
        - entities
        - repository
        - usecases
      - presentation
        - bloc
        - pages
        - widgets

The current codebase mainly uses `core/` plus `features/`; a `shared/` module is allowed by the guideline but is not part of the active implementation today.

The **`test` folder follows the active feature structure**, focusing on repositories, data sources, blocs and use cases that matter for the current product flow. It is not a strict one-to-one mirror of every file in `lib/`.

## Clean Folders
All the functionality of the app should follow a clean structure, and when used, the 3 layers
together form a *clean folder* that satisfies a restrictive set of rules.
The violations to these restrictions are detailed [here](./ARCHITECTURE_VIOLATIONS.md).
### Clean Folder Requirements
1. A clean folder must follow a clean structure divided into 3 layers (represented as folders in the codebase)
A. Data Layer
B. Domain Layer (Business Logic)
C. Presentation Layer (UI)
This is ALWAYS THE CASE, no exceptions
2. **Each layer can only communicate with the layer above or below it:**
- The Data Layer can only import from the Domain Layer
- The presentation layer can only import from the domain layer.
- The Domain Layer is a self-sustained layer with no imports from outer packages or folders in the app (it is written in pure dart).

#### Layer Requirements
##### Data Layer
- **Dependencies**: Relies exclusively on the Business Layer.
- **Structure**: Divided into three main components:
  1. **Data Sources**:
     - The sole classes in the codebase that interact with external services (e.g., APIs, LocalStorage, Cloud Storage, etc.).
     - Their functionalities are utilized by repository implementations for external data fetching.
  2. **Models**:
     - Extend entity classes from the Business Layer.
     - Responsible for parsing data from sources like APIs or Firestore into business objects, maintaining the same fields.
  3. **Repository Implementations**:
     - Fulfill the contracts (abstract classes) defined by the Business Layer's repositories.
     - Manage API/firebase/local storage interactions through the use of models.

##### Business Layer
- **Dependencies**: **Does not rely on any project dependencies** and is implemented purely in Dart (without Flutter packages).
- **Focus**: Solely concerned with business logic, abstracting away implementation details.
- **Structure**: Comprises three layers:
  1. **Entities**:
     - Define business objects used across the app for both data submission to APIs and data presentation in the UI.
     - Focused on implementing business logic without concerning data parsing (handled by Models) or UI presentation (handled by the Presentation Layer). Example: Age restrictions for users.
  2. **Params**
    - Optional classes that represent the parameters of the use cases, for example `SignInParams(String email, String password)`.
  3. **Use Cases**:
     - A piece of Business Logic that represents a single task the system needs to perform
     - Implements an abstract class with a `call` method, utilizing Repository Interfaces to execute specific functions. Examples include signup, login, upload_video, mark_read.
  4. **Repository Interfaces**:
     - Abstract classes that outline the necessary properties and methods for the application's features.
     - Imported by the use cases used in presentation, but implemented by the Data Layer, ensuring decoupling of business logic from specific APIs or UI design choices.


##### Presentation Layer
- **Dependencies**: Only interacts with the Business Layer, specifically with use cases.
- **Structure**: Organized into three folders:
  1. **Pages**
    - Contain the routed pages or screens of the respective feature
  2. **Blocs**:
    - Contain blocs and cubits for state management in the UI.
    - Only these components import use cases to fulfill UI logic requirements.
  3. **Widgets**
    - Contain the widgets specific to the respective feature

#### Exceptions
Apart from this, the data layer, business layer, and presentation layer can have imports from the `core` folder or, when it exists, a `shared` folder while still respecting the hierarchy. For example, the presentation layer can never import from the data layer.
