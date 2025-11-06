# AltTask Blueprint

## Overview

AltTask is a smart to-do list application built with Flutter. It allows users to manage their tasks, set priorities, and track their progress. The app features a clean and intuitive user interface, with both light and dark themes. It includes features like user authentication, task management with categories, and a productivity overview.

## Features

*   **Authentication:** Users can create an account, log in, and log out.
*   **Task Management:** Users can create, edit, and delete tasks.
*   **Categories:** Tasks can be organized by categories. Users can create new categories with custom names and colors directly from the task creation screen. Categories can be deleted with a long-press, which also removes all associated tasks.
*   **Due Dates:** Users can set due dates and times for their tasks.
*   **Task Sorting:** Tasks are automatically sorted into groups: "Due", "Today", "Tomorrow", "Upcoming", "No Date", and "Completed".
*   **Productivity Overview:** A statistics card shows the total number of tasks, completed tasks, and overdue tasks, along with a completion percentage.
*   **Search:** Users can search for tasks by title or category.
*   **Theming:** The app supports both light and dark themes, and users can toggle between them.

## Project Structure

*   `lib/main.dart`: The main entry point of the application.
*   `lib/services/auth_service.dart`: Handles user authentication.
*   `lib/services/category_service.dart`: Manages CRUD operations for categories.
*   `lib/screens/auth/auth_screen.dart`: The screen for login and registration.
*   `lib/screens/todo_list_screen.dart`: The main screen where users can see their to-do list and manage tasks.
*   `lib/category_provider.dart`: Manages the application's categories.
*   `lib/theme_provider.dart`: Manages the application's theme.
*   `lib/models/`: Contains the data models for `category.dart` and `todo_item.dart`.
*   `lib/widgets/`: Contains reusable widgets like `date_time_picker.dart`, `task_list_item.dart`, and `block_picker.dart`.

## Current Plan

*   **Unify Auth UI:** Removed the duplicate logos from the login and registration screens and resized the main logo for a consistent and clean user interface.
*   **Enable "Add" Button:** Fixed the issue where the "Add" button was not enabled by default when creating a new task, even when a category was already selected.
*   **Fix Task Creation:** Reverted the change that allowed task creation without a category. The "Add" button is now correctly disabled until both a task name and a category are selected. Also fixed an issue where selecting only a time for a task did not default the date to today.
*   **Deletable Categories:** Implemented the ability to delete categories by long-pressing on them. A confirmation dialog ensures that users don't accidentally delete a category and its associated tasks.
*   **Simplify UI:** Replaced the dropdown menu in the app bar with a direct logout button for a cleaner and more straightforward user experience.
*   **Remove Default Categories:** Removed the pre-built default categories that were appearing unexpectedly. The app will no longer create any default categories.
*   **Fix Type Mismatch:** Corrected a type mismatch error in `lib/screens/todo_list_screen.dart` by changing the `selectedColor` variable's type from `MaterialColor` to `Color`.
*   **Fix `BlockPicker` Error:** Resolved an error in `todo_list_screen.dart` by refactoring the `BlockPicker` widget into its own file (`lib/widgets/block_picker.dart`). This improves code organization and fixes the underlying issue.
*   **Fix Category Exception:** Resolved an issue where the application would throw an exception if a user tried to create a task before any categories were created.
*   **Streamline Category Creation:** Integrated category creation directly into the "add task" dialog, allowing users to add new categories on the fly.
*   **Add Dependencies:** Added the `flutter_colorpicker` package to support color selection for categories.
*   **Code Cleanup:** Deleted the now-redundant `lib/screens/category_management_screen.dart` file.
