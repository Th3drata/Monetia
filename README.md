# Spending Tracker - Money Flow

A comprehensive iOS expense tracking application built with SwiftUI, designed to help users manage their personal finances with ease.

## 🎯 Project Overview

Spending Tracker is a feature-rich financial management app that allows users to track income and expenses, visualize their financial situation, manage budgets, and maintain multiple accounts. The app emphasizes simplicity and efficiency while providing powerful insights into spending habits.

## ✨ Features

### MVP Features

#### 1. Transaction Management
- **Quick Transaction Entry**: Add transactions in seconds with amount, date, and type
- **Categorization**: Organize transactions using predefined categories (Food, Housing, Transportation, Entertainment, etc.)
- **Multiple Accounts**: Create and manage different accounts (Checking, Card, Cash, Savings)
- **Account Transfers**: Transfer money between accounts seamlessly
- **Transaction History**: View all transactions grouped by date with easy editing and deletion

#### 2. Financial Visualization
- **Current Balance Display**: View total balance across all accounts
- **Income vs Expenses**: Compare income and expenses for selected periods
- **Category Charts**: Visual breakdown of spending by category using pie charts (iOS 16+)
- **Period Selection**: Filter data by This Week, This Month, Last Month, or This Year

#### 3. Budget Management
- **Budget Creation**: Set overall budgets or category-specific budgets
- **Period Options**: Choose daily, weekly, monthly, or yearly budget periods
- **Visual Indicators**: Progress bars with color coding (green, orange, red)
- **Budget Tracking**: Real-time tracking of budget usage and remaining amounts
- **Alerts**: Visual warnings when approaching or exceeding budget limits

#### 4. Data Management
- **Local Storage**: All data saved locally using UserDefaults (easily upgradeable to Core Data)
- **CSV Export**: Export transaction data for external analysis
- **Data Persistence**: Automatic saving of all changes
- **iCloud Sync**: Placeholder for future cloud synchronization

#### 5. User Interface
- **Clean Design**: Modern, intuitive interface using SwiftUI
- **Tab Navigation**: Easy access to Home, Transactions, Budget, and Settings
- **Dark Mode Support**: Respects system appearance settings
- **Responsive Layout**: Optimized for all iPhone sizes

#### 6. Settings & Configuration
- **Category Management**: Create, edit, and delete custom categories
- **Multi-Language Support**: Available in English and French
- **Currency Support**: Default EUR currency (extensible to others)
- **Statistics**: View transaction and account counts

### Future Enhancements
- Recurring transactions
- Receipt photo attachments
- Home screen widgets
- Advanced analytics and trends
- Push notifications for budget alerts
- Multi-currency with exchange rates
- Bank integration
- Dark/light theme customization

## 🏗 Architecture

### Technical Stack
- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **Minimum iOS**: iOS 15.0
- **Data Storage**: UserDefaults (JSON encoding/decoding)
- **Charts**: Swift Charts (iOS 16+) with fallback for iOS 15

### Project Structure
```
SpendingTracker/
├── SpendingTrackerApp.swift       # App entry point
├── Models/
│   ├── Account.swift              # Account data model
│   ├── Transaction.swift          # Transaction data model
│   ├── Category.swift             # Category data model
│   └── Budget.swift               # Budget data model
├── Managers/
│   └── DataManager.swift          # Central data management
├── Views/
│   ├── ContentView.swift          # Main tab view
│   ├── HomeView.swift             # Dashboard and overview
│   ├── TransactionsView.swift    # Transaction list
│   ├── AddTransactionView.swift  # Transaction forms
│   ├── BudgetView.swift           # Budget management
│   └── SettingsView.swift         # Settings and export
└── Localization/
    ├── en.lproj/
    │   └── Localizable.strings    # English strings
    └── fr.lproj/
        └── Localizable.strings    # French strings
```

### Key Components

#### Data Models
- **Account**: Manages different financial accounts with balance tracking
- **Transaction**: Records financial transactions with categorization
- **Category**: Defines spending/income categories with visual attributes
- **Budget**: Sets and tracks spending limits

#### DataManager
- Singleton pattern for centralized data access
- CRUD operations for all data types
- Automatic balance calculations
- Analytics and reporting functions
- CSV export functionality

#### Views
- **HomeView**: Dashboard showing balances, charts, and account overview
- **TransactionsView**: List of all transactions with grouping by date
- **BudgetView**: Budget management with visual progress indicators
- **SettingsView**: Configuration and data export options

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0+ device or simulator
- macOS 12.0+ (for development)

### Installation

1. **Clone or download the project**
```bash
git clone <repository-url>
cd SpendingTracker
```

2. **Open in Xcode**
```bash
open SpendingTracker.xcodeproj
```

3. **Build and Run**
- Select a simulator or connected device
- Press `Cmd + R` to build and run

### First Time Setup

When you first launch the app:
1. **Create an Account**: Navigate to Home and tap the + button in the Accounts section
2. **Add Categories**: Default categories are automatically loaded
3. **Add Transactions**: Go to Transactions tab and tap + to record your first transaction
4. **Set Budgets**: Visit the Budget tab to create spending limits

## 📱 Usage Guide

### Managing Transactions
1. Tap the **Transactions** tab
2. Tap **+** to add a new transaction
3. Enter amount, select type (Income/Expense/Transfer), category, and account
4. Add optional notes
5. Tap **Save**

### Setting Budgets
1. Go to **Budget** tab
2. Tap **+** to create a budget
3. Enter budget name and amount
4. Select period (Daily/Weekly/Monthly/Yearly)
5. Choose scope (Overall or specific category)
6. Monitor progress with color-coded indicators

### Viewing Statistics
1. Visit the **Home** tab
2. Select time period (Week/Month/Year)
3. View income vs expenses
4. See spending breakdown by category
5. Check individual account balances

### Exporting Data
1. Go to **Settings** tab
2. Tap **Export Data**
3. Share or save the CSV file
4. Import to Excel, Google Sheets, or other tools

## 🎨 Customization

### Adding Custom Categories
1. Settings → Manage Categories → +
2. Enter category name
3. Select an icon from the grid
4. Choose a color
5. Preview and save

### Modifying Default Currency
Currently set to EUR. To change:
- Edit the default currency in `Account` model
- Update currency displays in views

## 🔒 Privacy & Security

- **Local Storage**: All data stored locally on device
- **No Analytics**: No tracking or analytics collection
- **No Account Required**: Works completely offline
- **Data Control**: Full control over data export and deletion

## 📊 Success Metrics (MVP)

- ✅ Handle 1000+ transactions without performance issues
- ✅ Transaction entry in under 10 seconds
- ✅ <1% error rate (crashes, data corruption)
- ✅ Accurate financial calculations
- ✅ 30%+ retention rate (3+ days post-install)

## 🐛 Known Issues

- PDF export not yet implemented (CSV only)
- iCloud backup/restore placeholders (not functional)
- Multi-currency limited to display only (no conversion)
- Charts require iOS 16+ (fallback list for iOS 15)

## 🛣 Roadmap

### Version 1.1
- [ ] Core Data migration for better performance
- [ ] Recurring transactions
- [ ] Receipt photo attachments
- [ ] Budget alerts/notifications

### Version 1.2
- [ ] Home screen widgets
- [ ] Advanced analytics
- [ ] PDF export
- [ ] Multi-currency support

### Version 2.0
- [ ] Bank account integration
- [ ] Cloud synchronization
- [ ] macOS companion app
- [ ] Family sharing

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is available for personal and commercial use.

## 📧 Contact

For questions or support, please open an issue in the repository.

---

**Note**: This is an MVP (Minimum Viable Product). The focus is on core functionality and user experience. Future versions will expand capabilities based on user feedback.
