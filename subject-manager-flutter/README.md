# Subject Management Flutter App

This project is a Flutter application designed for managing subjects in a clean and modern interface. It allows users to add, edit, delete, and view subjects with ease.

## Features

- **Add Subjects**: Users can add new subjects with details such as name, code, and teacher.
- **Edit Subjects**: Users can modify existing subjects.
- **Delete Subjects**: Users can remove subjects from the list.
- **View Subjects**: A comprehensive list of all subjects with detailed views for each subject.

## Project Structure

```
subject-manager-flutter
├── android                # Android platform-specific code
├── ios                    # iOS platform-specific code
├── lib                    # Main application code
│   ├── main.dart          # Entry point of the application
│   └── src                # Source files
│       ├── app.dart       # Main application widget
│       ├── models         # Data models
│       │   └── subject.dart
│       ├── pages          # UI pages
│       │   ├── subject_list_page.dart
│       │   ├── subject_detail_page.dart
│       │   └── edit_subject_page.dart
│       ├── widgets        # Reusable widgets
│       │   ├── subject_tile.dart
│       │   ├── subject_form.dart
│       │   └── dialogs.dart
│       ├── services       # Business logic
│       │   └── subject_service.dart
│       ├── repositories    # Data management
│       │   └── subject_repository.dart
│       ├── providers      # State management
│       │   └── subject_provider.dart
│       ├── themes         # App themes
│       │   └── app_theme.dart
│       └── utils          # Utility functions
│           └── validators.dart
├── test                   # Unit tests
│   └── subject_service_test.dart
├── pubspec.yaml           # Project configuration
├── analysis_options.yaml   # Analyzer settings
├── .gitignore             # Git ignore file
└── README.md              # Project documentation
```

## Getting Started

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd subject-manager-flutter
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Run the application**:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.