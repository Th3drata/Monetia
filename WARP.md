# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

SpendingTracker is a SwiftUI-based iOS expense tracking application (iOS 15.0+) that helps users manage personal finances through transaction tracking, budget management, and account balancing.

## Development Environment

**Prerequisites:**
- Xcode 14.0 or later
- macOS 12.0+
- iOS 15.0+ device or simulator

**Note:** This is a standalone Swift package project without an Xcode project file (.xcodeproj) yet. To work with this codebase:

1. Create a new Xcode project: File → New → Project → iOS → App
2. Copy all source files into the project maintaining the directory structure
3. Or use Swift Package Manager if the project structure supports it

## Common Development Commands

### Building & Running
```bash
# Open project in Xcode (once created)
open SpendingTracker.xcodeproj

# Build from command line (requires xcodeproj setup)
xcodebuild -scheme SpendingTracker -destination 'platform=iOS Simulator,name=iPhone 14' build

# Run on simulator (from Xcode)
# Cmd + R
```

### Testing
Currently no test suite exists. When adding tests:
```bash
# Run tests
xcodebuild test -scheme SpendingTracker -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Architecture

### Data Flow Pattern
The app uses a centralized **Singleton DataManager** with SwiftUI's `@Published` properties for state management:

1. **DataManager.shared** - Single source of truth for all app data
2. Injected via `@EnvironmentObject` from `SpendingTrackerApp.swift`
3. All views observe and modify data through this shared instance
4. Data persists automatically to UserDefaults using JSON encoding/decoding

### Core Architecture Principles

**State Management:**
- DataManager is an `ObservableObject` with `@Published` properties
- Changes trigger automatic UI updates across all views
- No separate ViewModels - DataManager serves this role

**Balance Calculations:**
- Account balances are stored values, NOT computed
- When transactions are added/modified/deleted, DataManager updates account balances accordingly
- Methods: `updateAccountBalance()` and `revertAccountBalance()` handle all balance adjustments
- This ensures balance accuracy even for transfers between accounts

**Data Persistence:**
- All data stored in UserDefaults as JSON
- Automatic saving after any CRUD operation
- Keys: "accounts", "transactions", "categories", "budgets"
- Future migration path to Core Data exists but not yet implemented

### Model Relationships

```
Transaction
  ├─ accountId (UUID) → Account
  ├─ toAccountId? (UUID) → Account (for transfers)
  └─ category (Category) - Embedded, not ID reference

Budget
  ├─ categoryId? (UUID) → Category (nil = overall budget)
  └─ period (BudgetPeriod) - enum with date calculation methods

Account
  └─ balance (Decimal) - Stored value, updated by transactions

Category
  └─ Embedded in Transaction, not stored by reference
```

**Important:** Category is stored directly within Transaction (not as an ID reference), which means category updates won't retroactively affect historical transactions.

### Key Components

**Views Structure:**
- `ContentView.swift` - TabView container with 4 tabs
- `HomeView.swift` - Dashboard with balance, charts, accounts
- `TransactionsView.swift` - Transaction list grouped by date
- `AddTransactionView.swift` - Transaction entry/edit form
- `BudgetView.swift` - Budget creation and tracking
- `SettingsView.swift` - Category management and data export

**Data Models:**
All models conform to `Identifiable` and `Codable`:
- `Account` - Financial accounts with balance tracking
- `Transaction` - Financial transactions with type (income/expense/transfer)
- `Category` - Spending categories with visual attributes (icon, color)
- `Budget` - Spending limits with period-based tracking

### Localization

**Supported Languages:** English, French

**String Files:**
- `Localization/en.lproj/Localizable.strings`
- `Localization/fr.lproj/Localizable.strings`

**Usage:** All user-facing strings use `NSLocalizedString()` or `Text("key")` which automatically looks up translations.

**Adding New Strings:** Add to both English and French localization files with identical keys.

## Code Patterns & Best Practices

### When Adding Features

**Transaction Operations:**
Always use DataManager methods, never modify arrays directly:
```swift
// ✅ Correct
dataManager.addTransaction(transaction)
dataManager.updateTransaction(transaction)
dataManager.deleteTransaction(transaction)

// ❌ Wrong - breaks balance calculations
dataManager.transactions.append(transaction)
```

**Account Balance:**
Never modify account balance directly. The DataManager handles this:
```swift
// ✅ Correct
dataManager.addTransaction(transaction) // Updates balance automatically

// ❌ Wrong
account.balance += amount
dataManager.updateAccount(account)
```

**Period-Based Queries:**
Use DataManager's analytics methods for date filtering:
```swift
let period = DateInterval(start: startDate, end: endDate)
let income = dataManager.getIncomeForPeriod(period)
let expenses = dataManager.getExpensesForPeriod(period)
let expensesByCategory = dataManager.getExpensesByCategory(for: period)
```

### SwiftUI Patterns Used

- `@EnvironmentObject` for DataManager injection
- `@State` for local view state
- `@Published` for observable properties
- `.sheet()` for modal presentations
- `NavigationView` / `NavigationLink` for navigation
- `TabView` for main navigation structure

### iOS Version Compatibility

**Charts:** Swift Charts (iOS 16+) with fallback for iOS 15
```swift
if #available(iOS 16.0, *) {
    Chart { /* ... */ }
} else {
    // Fallback to list view
}
```

When adding features requiring iOS 16+, always provide iOS 15 fallback.

## Data Export

The app supports CSV export via `dataManager.exportToCSV()`:
- Returns formatted CSV string
- Includes: Date, Type, Category, Amount, Account, Notes
- Accessible from Settings tab via share sheet

## Known Limitations

- **Storage:** UserDefaults only - not optimized for >1000 transactions
- **Charts:** Requires iOS 16+ (fallback list view for iOS 15)
- **Currency:** EUR hardcoded, no multi-currency conversion
- **iCloud:** Backup/restore UI exists but not functional
- **PDF Export:** Not implemented (CSV only)

## Future Migration Paths

**Core Data Migration:**
When implementing, preserve the DataManager API so views don't need changes. Replace UserDefaults persistence with Core Data stack while maintaining the same CRUD interface.

**Category Reference Migration:**
Currently Category is embedded in Transaction. If moving to ID-based references, add migration logic to handle historical data.
