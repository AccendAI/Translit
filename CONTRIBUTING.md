# Contributing to Translit

Thank you for your interest in contributing! This document will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/Translit.git`
3. Open `Translit.xcodeproj` in **Xcode 16.0+**
4. Resolve Swift Package Manager dependencies via **File → Packages → Resolve Package Versions**

## Branch Naming

Use the following prefixes for your branches:

- `feature/description` — New features or enhancements
- `bugfix/description` — Bug fixes
- `docs/description` — Documentation changes
- `refactor/description` — Code refactoring without feature changes

## Commit Conventions

Write clear, descriptive commit messages:

- Use the present tense (e.g., "Add dark mode support" not "Added dark mode support")
- Keep the first line under 72 characters
- Reference issues when applicable (e.g., `Fixes #123`)

## Submitting Changes

1. Create a branch from `main`
2. Make focused, atomic commits
3. Add or update unit tests in `TranslitTests/` as needed
4. Ensure the project builds and all tests pass (`Cmd+U` in Xcode)
5. Run SwiftLint locally and fix any violations
6. Fill out the pull request template completely

## Code Style

- Follow the existing Swift style in the project
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Prefer `let` over `var`, and avoid force-unwrapping when possible
- Keep functions focused and under ~60 lines when practical

## Testing

- Write unit tests for business logic in `TranslitTests/`
- Test UI changes on both the iOS Simulator and a physical device when possible
- Ensure all existing tests pass before submitting your PR

## Reporting Bugs

If you found a bug but don't have a fix, please open an issue using the Bug Report template. Include:

- iOS version and device model
- App version
- Steps to reproduce
- Expected vs. actual behavior

## Questions?

Open a [Discussion](https://github.com/mphassani/Translit/discussions) or issue if you need help!
