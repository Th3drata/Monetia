# Monetia v1.2 Release Notes

## 🎉 What's New

### 🔄 Recurring Transactions
**The most requested feature is here!** Set up transactions that repeat automatically.

- **Flexible Frequencies**: Choose from daily, weekly, monthly, or yearly recurrence
- **Smart Scheduling**: For weekly transactions, select the specific day of the week
- **Monthly Precision**: For monthly transactions, choose the day of the month (1-31)
- **Optional End Date**: Set when recurring transactions should stop, or let them continue indefinitely
- **Auto-Generation**: Future transactions are automatically created up to 3 months ahead
- **Smart Balance Calculation**: Scheduled transactions don't affect your current balance until their date arrives

### 📅 Upcoming Transactions View
Stay informed about what's coming next.

- **Dedicated View**: New "Upcoming" button in the Transactions tab
- **Current Month Focus**: See all scheduled transactions for the current month
- **Visual Indicators**: Future transactions are marked with a "Scheduled" badge
- **Reduced Opacity**: Easy visual distinction between past and future transactions
- **Recurring Icon**: Recurring transactions display a repeat icon for quick identification

### ⚙️ Recurrence Management
Full control over your recurring transactions.

- **Toggle Control**: Activate or deactivate recurrence on any existing recurring transaction
- **Smart Cleanup**: When disabling recurrence, all future occurrences are automatically deleted
- **Confirmation Alert**: Safety prompt before deleting scheduled transactions
- **View Details**: See recurrence frequency and schedule in the edit view
- **Keep History**: Disabling recurrence preserves the current transaction in your history

### 🗑️ Account Deletion
Easily manage your account list.

- **Context Menu**: Long-press any account to reveal the delete option
- **Haptic Feedback**: Tactile confirmation when deleting
- **Quick Access**: No need to navigate through multiple screens

### 📱 Enhanced User Experience
Small touches that make a big difference.

- **Haptic Feedback**: Tactile responses throughout the app for button taps, saves, and important actions
- **Improved Translations**: Day of week names now properly localized in French
- **Fixed Total Balance**: Initial account balances now correctly reflected in total balance calculation

### 💻 macOS Support
Work on your expenses from your Mac!

- **Mac Catalyst**: Full compatibility with macOS via Mac Catalyst
- **Native Experience**: Optimized layout with stack navigation (no sidebar)
- **Minimum Frame Size**: 800x600 window for comfortable use
- **Platform-Specific Code**: Haptic feedback disabled on Mac, proper file handling

## 🐛 Bug Fixes

- **Fixed**: Total balance not updating when creating a new account with an initial balance
- **Fixed**: Day of week names appearing in English instead of user's selected language
- **Fixed**: iPad/Mac showing sidebar navigation instead of bottom tab bar
- **Improved**: Balance calculations now properly exclude future transactions

## 🎨 UI/UX Improvements

- **Scheduled Badge**: Orange badge on future transactions for easy identification
- **Recurring Icon**: Small repeat icon on recurring transactions
- **Opacity Effect**: Future transactions shown with 60% opacity
- **Alert Dialogs**: Proper confirmation dialogs for destructive actions
- **Localization**: Added 7+ new localized strings for recurrence features

## 📊 Technical Details

### New Models & Features
- `TransactionRecurrence` struct with support for complex recurrence patterns
- `RecurrenceFrequency` enum (daily, weekly, monthly, yearly)
- Recurring group ID system for managing transaction series
- Smart date calculation with `nextDate(after:)` function

### New Functions
- `scheduleRecurringTransactions()`: Generate future occurrences
- `updateRecurringTransactions()`: Check and generate new transactions on app launch
- `deleteFutureRecurringTransactions()`: Clean up when disabling recurrence
- `getTotalBalance()`: Simplified to use actual account balances

### Localization
Added support for:
- Recurrence UI elements (English & French)
- Day of week names (all 7 days)
- Recurrence frequencies (daily/weekly/monthly/yearly)
- Alert messages and confirmations
- Upcoming transactions view

## 🚀 Getting Started

### Using Recurring Transactions

1. **Create a Recurring Transaction**:
   - Tap **Transactions** → **+**
   - Fill in transaction details
   - Toggle **"Recurring Transaction"**
   - Select frequency (daily/weekly/monthly/yearly)
   - For weekly: Choose day of the week
   - For monthly: Choose day of the month
   - Optionally set an end date
   - Tap **Save**

2. **View Upcoming Transactions**:
   - Go to **Transactions** tab
   - Tap **Upcoming** button (top left)
   - See all scheduled transactions for current month

3. **Manage Recurrence**:
   - Tap any recurring transaction
   - Toggle **"Recurrence Active"** off
   - Confirm to disable and delete future occurrences

### Deleting Accounts

1. Long-press on any account in the Home view
2. Tap **Delete** from the context menu
3. Account and all associated data will be removed

## 📈 Performance & Compatibility

- **Tested on**: iOS 15.0 - iOS 18.6
- **macOS**: Compatible with Mac Catalyst
- **Performance**: Handles 1000+ transactions with recurring support
- **Stability**: Comprehensive testing on iPhone, iPad, and Mac

## 🔄 Migration Notes

- No data migration required
- Existing data fully compatible
- New fields automatically added to data models
- JSON backup/restore includes recurring transaction data

## 📝 What's Next?

Version 1.3 is already in planning with:
- Core Data migration for enhanced performance
- Receipt photo attachments
- Budget alert notifications
- Advanced analytics and trends

## 🙏 Feedback

We'd love to hear your thoughts on the new recurring transactions feature! Please report any issues or suggestions through the repository.

---

**Version**: 1.2  
**Release Date**: November 2025  
**Build**: Compatible with iOS 15.0+, macOS (Mac Catalyst)  
**Language Support**: English, Français (French)  
**Currency Support**: EUR, USD, GBP, CHF, JPY, CNY
