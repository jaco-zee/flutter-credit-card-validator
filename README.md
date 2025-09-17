# Card Submitter

A Flutter app for managing credit cards with camera scanning and filtering capabilities.

## What it does

- Scan credit cards with your camera or enter details manually
- Store cards locally (CVV is never saved)
- Filter and search your saved cards
- Validate card numbers using the Luhn algorithm
- Block cards from specific countries if needed
- Detect card brands automatically (Visa, Mastercard, etc.)

## How it's built

The app follows a feature-based structure with clean separation of concerns:

```
lib/
├── core/           # Utilities and shared code
├── data/           # Storage and data models  
├── domain/         # Business entities
├── features/       # Main app features
│   ├── cards/      # Card list and management
│   ├── card_form/  # Adding new cards
│   ├── banned_countries/
│   └── scan/       # Camera scanning
└── app/            # App setup and routing
```

Each feature uses the Cubit pattern for state management, keeping business logic separate from UI code.

## Getting started

You'll need Flutter 3.4.0 or newer.

```bash
git clone <repository-url>
cd card_submitter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

For camera scanning to work, you'll need to add camera permissions to your iOS/Android config files (see the platform setup sections below).

### iOS setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan credit cards</string>
```

### Android setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

## Running tests

```bash
flutter test
```

## How to use

### Adding cards

1. Tap the + button
2. Fill in the card details:
   - Card number (or use "Scan Card")
   - Cardholder name
   - Expiry date (MM/YY format)
   - CVV
   - Issuing country
3. Tap "Save Card"

### Scanning cards

The camera scanner can usually pick up the card number, and sometimes the name and expiry date if they're clearly visible. If it doesn't work well, just enter the details manually.

### Filtering cards

Use the filter button to search by card brand, country, or the last 4 digits.

## Dependencies

### Core Dependencies
- `flutter_bloc` (^8.1.3): State management
- `equatable` (^2.0.5): Value equality for states
- `hive` (^2.2.3): Local storage
- `hive_flutter` (^1.1.0): Flutter integration for Hive
- `get_it` (^7.6.4): Dependency injection
- `card_scanner` (^1.0.2): OCR card scanning
- `intl` (^0.18.1): Internationalization utilities

### Development Dependencies
- `build_runner` (^2.4.9): Code generation
- `hive_generator` (^2.0.1): Hive adapter generation
- `mocktail` (^1.0.3): Mocking for tests
- `bloc_test` (^9.1.4): Testing utilities for Cubits
- `flutter_lints` (^4.0.0): Linting rules

### Supported card types

- Visa (starts with 4)
- Mastercard (starts with 51-55 or 2221-2720)  
- American Express (starts with 34 or 37)
- Discover (starts with 6011, 65, 644-649, or 622)
- Diners Club (starts with 300-305, 36, or 38)
- JCB (starts with 3528-3589)

## Common issues

**Scanner not working?** Make sure you have camera permissions set up and good lighting.

**Save button disabled?** All fields are required - card number, name, expiry, CVV, and country.

**Build errors?** Try `flutter clean` then `dart run build_runner build --delete-conflicting-outputs`.

**Database errors?** The app handles this automatically by clearing and rebuilding storage when needed.

## What's under the hood

### Dependencies worth knowing about

- `flutter_bloc` - State management
- `hive` & `hive_flutter` - Local storage
- `card_scanner` - OCR for reading cards
- `equatable` - Makes state comparisons easier
- `get_it` - Dependency injection

### Card validation

The app validates card numbers using the Luhn algorithm, but for testing purposes it's currently set to accept any 13-19 digit number. Card brands are detected from the first few digits (BIN ranges).

## Validation Rules

### Card Number
- Must pass Luhn algorithm validation (relaxed for testing - accepts any 13-19 digits)
- Must be 13-19 digits long
- Automatically normalized (spaces and dashes removed)

### Card Holder Name
- Required field - must be non-empty
- Automatically trimmed and limited to 50 characters
- Can be auto-filled from card scanning if detected

### Expiry Date
- Required field in MM/YY format
- Must be a future date (current month/year or later)
- Month must be valid (01-12)
- Can be auto-filled from card scanning if detected

### CVV
- 3 digits for Visa, Mastercard, Discover, Diners Club, JCB
- 4 digits for American Express
- Never stored persistently

### Country Validation
- Must be selected from predefined list
- Validated against banned countries list
- Banned countries configurable per app instance

## Security Features

1. **CVV Protection**: CVV is never persisted to storage
2. **Data Normalization**: Card numbers stored in normalized format
3. **Local Storage**: All data stored locally using Hive with automatic schema migration
4. **Input Validation**: Comprehensive validation at multiple layers
5. **Error Handling**: Proper exception handling with logging for debugging
6. **Data Integrity**: Automatic cleanup and migration of incompatible data schemas

## Troubleshooting

### Card Scanner Issues

**Problem**: Camera permission denied
**Solution**: Ensure camera permissions are properly configured in platform files

**Problem**: Card number not detected
**Solution**: Ensure good lighting and card is flat with number clearly visible

**Problem**: Scanned data incomplete
**Solution**: Card holder name and expiry date detection depends on card design and lighting - use manual entry if OCR fails

### Build Issues

**Problem**: Hive adapter generation errors
**Solution**: Run `flutter clean` then `dart run build_runner build --delete-conflicting-outputs`

**Problem**: Schema migration errors
**Solution**: Check console for migration logs - the app automatically handles incompatible data by clearing and rebuilding storage

**Problem**: Platform-specific build errors
**Solution**: Ensure minimum SDK versions are met (iOS 11.0+, Android API 21+)

### Validation Issues

**Problem**: "Card already exists" error showing twice
**Solution**: This has been fixed in the latest version with improved error state management

**Problem**: Save button disabled despite valid input
**Solution**: Ensure all required fields are filled: card number, holder name, expiry date, CVV, and country

**Problem**: Luhn validation failing for test cards
**Solution**: Testing mode is enabled - any 13-19 digit number is accepted for QA purposes

## Development

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters  
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Start the app
flutter run

# Check for issues
flutter analyze
```

## Contributing

The codebase follows standard Flutter patterns. If you're contributing:

- Follow the existing architecture (Cubit for state management)
- Add tests for new features  
- Run `flutter analyze` to check for issues
- Don't use empty catch blocks - handle errors properly

## License

This project is licensed under the MIT License - see the LICENSE file for details.
