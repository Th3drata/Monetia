import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("home", systemImage: "house.fill")
                }
                .tag(0)
            
            TransactionsView()
                .tabItem {
                    Label("transactions", systemImage: "list.bullet")
                }
                .tag(1)
            
            BudgetView()
                .tabItem {
                    Label("budget", systemImage: "chart.pie.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}
