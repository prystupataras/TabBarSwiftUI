//
//  ContentView.swift
//  TabBarSwiftUI
//
//  Created by Taras Prystupa on 26.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                TabView(selection: $activeTab) {
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                        Tab.init(value: tab) {
                            Text(tab.rawValue)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                TabView(selection: $activeTab) {
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            
            InteractiveCapsuleTabBar(activeTab: $activeTab)
        }
    }
}

/// Interactive tab bar
struct InteractiveTabBar: View {
    @Binding var activeTab: TabItem
    ///View properties
    @Namespace private var animation
    ///Storing the location of the Tab buttons so they can be used ti identify the currently dragged tab
    @State private var tabButtonLocation: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    ///Using this, we can animate the changes in the tab bar without animating the actual tab view. When the gesture is released, the changes are pushed to the tab view.
    @State private var activeDraggingTab: TabItem?
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.25), radius: 5)))
                .ignoresSafeArea()
                .padding(.top, 10)
        }
        .coordinateSpace(.named("TABBAR"))
    }
    
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbol)
                .symbolVariant(.fill)
                .frame(width: isActive ? 50 : 25, height: isActive ? 50 : 25)
                .background {
                    if isActive {
                        Circle()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundStyle(isActive ? .white : .primary)
            
            Text(tab.rawValue)
                .font(.caption2)
                .foregroundStyle(isActive ? .blue : .gray)
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .contentShape(.rect)
        .padding(isActive ? 0 : 20)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocation[tab.index] = newValue
        })
        
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged { value in
                    let location = value.location
                    /// Checling if the location falls within any stored locations; if so, switching to the appropriate index
                    if let index = tabButtonLocation.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                }.onEnded { _ in
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }
                    
                    activeDraggingTab = nil
                },
            isEnabled: activeTab == tab
        )
    }
}
/// Interactive capsule tab bar
struct InteractiveCapsuleTabBar: View {
    @Binding var activeTab: TabItem
    ///View properties
    @Namespace private var animation
    ///Storing the location of the Tab buttons so they can be used ti identify the currently dragged tab
    @State private var tabButtonLocation: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    ///Using this, we can animate the changes in the tab bar without animating the actual tab view. When the gesture is released, the changes are pushed to the tab view.
    @State private var activeDraggingTab: TabItem?
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 40)
//        .padding(5)
        .background {
            Capsule()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.25), radius: 5)))
        }
        .coordinateSpace(.named("TABBAR"))
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbol)
                .symbolVariant(.fill)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isActive {
                Capsule()
                    .fill(.blue.gradient)
                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
            }
        }
        .contentShape(.rect)
        .padding(isActive ? 0 : 20)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocation[tab.index] = newValue
        })
        
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged { value in
                    let location = value.location
                    /// Checling if the location falls within any stored locations; if so, switching to the appropriate index
                    if let index = tabButtonLocation.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                }.onEnded { _ in
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }
                    
                    activeDraggingTab = nil
                },
            isEnabled: activeTab == tab
        )
    }
}

#Preview {
    ContentView()
}

enum TabItem: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case notification = "Notification"
    case settings = "Settings"
    
    var symbol: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .notification: return "bell"
        case .settings: return "gearshape"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
