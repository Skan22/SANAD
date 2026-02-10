# Contributing to Second Voice

Thank you for your interest in contributing to Second Voice! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background, identity, or experience level. We expect all participants to:

- Be respectful and considerate
- Welcome diverse perspectives
- Focus on what is best for the community
- Show empathy towards others

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Git
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)
- Basic understanding of Dart and Flutter
- Familiarity with accessibility principles (helpful but not required)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/SANAD.git
   cd SANAD
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/ORIGINAL-OWNER/SANAD.git
   ```

## Development Setup

```bash
# Navigate to the mobile app directory
cd SecondVoice_MVP/mobile_app

# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run --debug

# Run tests
flutter test
```

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates.

**When creating a bug report, include:**

- Clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots/recordings if applicable
- Device information (OS, version, model)
- App version or commit hash

**Use this template:**

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - Device: [e.g. Pixel 6]
 - OS: [e.g. Android 13]
 - App Version: [e.g. 1.0.0]
```

### Suggesting Features

We welcome feature suggestions! Before submitting:

- Check if the feature has already been suggested
- Ensure it aligns with the project's accessibility mission
- Consider the impact on users with disabilities

**Feature request template:**

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Accessibility considerations**
How does this feature improve accessibility?

**Additional context**
Any other context or screenshots.
```

## Coding Standards

### Dart/Flutter Style Guide

Follow the official [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables, functions, and parameters
- Use `UpperCamelCase` for types and classes
- Use `lowercase_with_underscores` for libraries and source files
- Prefer `const` over `final` when possible
- Always declare types for public APIs

### Code Formatting

```bash
# Format all Dart files
flutter format .

# Analyze code for issues
flutter analyze
```

### Accessibility Requirements

All UI contributions must meet WCAG 2.1 Level AA standards:

- **Color Contrast:** Minimum 4.5:1 ratio for normal text
- **Touch Targets:** Minimum 44x44 logical pixels
- **Semantic Labels:** All interactive elements must have labels
- **Dynamic Typography:** Support text scaling from 20pt to 40pt
- **Screen Reader Support:** Test with TalkBack (Android) or VoiceOver (iOS)

### File Organization

```
lib/
├── models/          # Data models only (no business logic)
├── screens/         # Full-screen UI components
├── services/        # Business logic and data access
├── theme/           # Theming and styling
└── widgets/         # Reusable UI components
```

## Testing Guidelines

### Unit Tests

- All business logic must have unit tests
- Aim for 80%+ code coverage for service classes
- Test edge cases and error scenarios

```dart
// Example test structure
void main() {
  group('DiarizationService', () {
    test('should detect speaker change after pause', () {
      // Arrange
      final service = DiarizationService(pauseThreshold: 1.5);
      
      // Act
      final result = service.detectSpeakerChange(lastSpeechTime);
      
      // Assert
      expect(result, isTrue);
    });
  });
}
```

### Widget Tests

- Test UI components in isolation
- Verify accessibility properties
- Test user interactions

```dart
testWidgets('MessageBubble displays speaker name', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MessageBubble(
        message: ConversationMessage(
          text: 'Hello',
          speakerId: 0,
          speakerName: 'Alice',
        ),
      ),
    ),
  );
  
  expect(find.text('Alice'), findsOneWidget);
});
```

### Integration Tests

- Test complete user flows
- Verify cross-component interactions
- Test on multiple platforms

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, no logic change)
- **refactor:** Code refactoring
- **test:** Adding or updating tests
- **chore:** Maintenance tasks

### Examples

```
feat(diarization): add configurable pause threshold

- Added slider in settings for 1-3 second range
- Persisted value to SharedPreferences
- Updated algorithm to use custom threshold

Closes #123
```

```
fix(accessibility): improve color contrast for speaker bubbles

- Updated speaker colors to meet WCAG 4.5:1 ratio
- Added contrast validator utility
- Tested with accessibility scanner

Fixes #456
```

## Pull Request Process

### Before Submitting

1. **Update from upstream:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests:**
   ```bash
   flutter test
   flutter analyze
   ```

3. **Format code:**
   ```bash
   flutter format .
   ```

4. **Test manually:**
   - Test on at least one platform
   - Verify accessibility features
   - Check demo mode still works

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed
- [ ] Accessibility verified

## Screenshots/Recordings
If UI changes, provide before/after screenshots

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
```

### Review Process

1. **Automated checks:** CI runs tests and linting
2. **Code review:** At least one maintainer reviews
3. **Accessibility review:** For UI changes
4. **Testing:** Maintainer tests on target platforms
5. **Merge:** Once approved, maintainer merges

### After Merge

- Delete your feature branch
- Update your fork:
  ```bash
  git checkout main
  git pull upstream main
  git push origin main
  ```

## Recognition

All contributors will be acknowledged in:
- GitHub contributors page
- Release notes
- Project documentation (for significant contributions)

## Questions?

- Open a discussion on GitHub
- Check existing documentation
- Reach out to maintainers

## Thank You!

Your contributions help make Second Voice better for the deaf and hard-of-hearing community. Every improvement, no matter how small, makes a difference.

---

**Happy coding! 💙**
