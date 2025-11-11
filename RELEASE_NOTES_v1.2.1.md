# Monetia v1.2.1 Release Notes

## 🎉 What's New

### 🔄 Account Management
**Drag-and-drop account reordering** - Finally here!
- Tap the ↕️ icon in the Accounts section to enable edit mode
- Drag accounts up and down using the handle (☰) on the right
- Your custom order is automatically saved
- Tap ✓ when done

### 💰 Currency Display
**Account currency in transactions**
- Transaction list now displays the currency symbol from the source account
- Example: `+ 127.43 €`, `- $50.00`, `+ £25.50`
- Automatically adapts to each account's currency setting

### 🔄 Pull-to-Refresh
**Refresh your data anywhere**
- Added to Home and Transactions views
- Pull down from the top to refresh
- Updates recurring transactions and recalculates balances
- Success haptic feedback when complete

### 📅 Improved Upcoming Transactions
**Extended view period**
- Now shows transactions for the **next 3 months** instead of just current month
- See all your upcoming recurring transactions at a glance
- Better planning for subscriptions and recurring expenses

### 🗑️ Smart Recurring Deletion
**Delete entire series**
- When you delete a recurring transaction, all future occurrences are removed too
- No more manual cleanup of scheduled transactions
- Makes sense: deleting a subscription cancels all future charges

### 📍 Location Support (Beta)
**Add locations to transactions**
- New location picker with MapKit integration
- Search with autocomplete for addresses and places
- Interactive map preview before saving
- Stores location name, address, and coordinates with each transaction

**Note:** Location picker requires manual setup in Xcode (see README)

### 🐛 Bug Fixes
- **Fixed**: Decimal comma support - European format (127,43) now works correctly
- **Fixed**: Account balance calculation now includes initial balance
- **Fixed**: Day of week translation in French for recurring transactions
- **Fixed**: Location picker no longer flashes back to search after selection
- **Fixed**: Upcoming transactions filter now correctly shows future occurrences

## 🔧 Technical Improvements
- Added debug logging for recurring transaction scheduling
- Improved `getTotalBalance()` to use actual account balances
- Better error handling in decimal parsing across all input fields
- Enhanced `List` usage with proper `editMode` for drag-and-drop

## 📱 User Experience
- Haptic feedback on account reordering
- Visual feedback during pull-to-refresh
- Smooth animations for edit mode transitions
- Better currency formatting throughout the app

## 🌐 Localization
Added French/English translations for:
- `recurrence_active` - "Recurrence Active" / "Récurrence Active"
- `location` - "Location" / "Lieu"
- `search_location` - "Search for a place" / "Rechercher un lieu"
- `remove_location` - "Remove Location" / "Supprimer le Lieu"

## 🔍 Debug Features
For developers:
- Console logging when creating recurring transactions
- Shows number of occurrences generated
- Displays dates of future transactions
- Helps troubleshoot recurring transaction issues

## 📊 What's Coming in v1.3
- Receipt photo attachments
- Budget alert notifications
- Advanced analytics and trends
- Core Data migration for better performance

## 🐛 Known Issues
- Location picker requires manual file addition in Xcode
- Pull-to-refresh adds 0.5s artificial delay (intentional for UX)

## 📝 Upgrade Notes
- No data migration required
- All existing data remains compatible
- Location fields added to transactions (optional, defaults to nil)
- Account order is preserved from previous version

## 💡 Tips
1. **Account Reordering**: Long-press no longer works - use the edit mode button instead
2. **Recurring Transactions**: Create them with a future date if you don't want them to start today
3. **Upcoming View**: Now shows 3 months ahead - perfect for planning
4. **Pull-to-Refresh**: Use this if your recurring transactions don't appear right away
5. **Location**: Tap the X button on a selected location to remove it before saving

## 🙏 Feedback
Found a bug? Have a feature request? Open an issue on GitHub!

---

**Version**: 1.2.1  
**Release Date**: November 9, 2025  
**Build**: iOS 15.0+, macOS (Mac Catalyst)  
**Language Support**: English, Français  
**Currency Support**: EUR, USD, GBP, CHF, JPY, CNY

**What's Changed**: https://github.com/Th3drata/Monetia/compare/v1.2.0...v1.2.1
