
# AltTask Blueprint

## Overview

AltTask is a smart to-do list application built with Flutter. It allows users to manage their tasks, set priorities, and track their progress. The app features a clean and intuitive user interface, with both light and dark themes.

## Features

*   **Authentication:** Users can create an account, log in, and log out.
*   **Task Management:** Users can create, edit, and delete tasks.
*   **Themeing:** The app supports both light and dark themes, and users can toggle between them.

## Project Structure

*   `lib/main.dart`: The main entry point of the application.
*   `lib/auth/auth_provider.dart`: Handles user authentication.
*   `lib/screens/login_screen.dart`: The login screen.
*   `lib/screens/register_screen.dart`: The registration screen.
*   `lib/screens/todo_list_screen.dart`: The main screen where users can see their to-do list.
*   `lib/theme_provider.dart`: Manages the application's theme.

## Current Plan

*   **Fix `BuildContext` issue:** The app is currently crashing on startup due to a `BuildContext` issue in the `_AuthWrapperState`. I will fix this by moving the `checkCurrentUser()` call to a `WidgetsBinding.instance.addPostFrameCallback`.
