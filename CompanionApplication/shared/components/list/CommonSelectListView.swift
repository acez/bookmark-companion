//
//  CommonListView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public protocol CreateNotFoundItemHandler {
    func createItem(text: String)
}

public protocol CommonListItem: Hashable, Identifiable {
    func getDisplayText() -> String
    func isFavorite() -> Bool
}

extension CommonListItem {
    public func isFavorite() -> Bool {
        return false
    }
}

public struct CommonSelectListView<T: CommonListItem>: View {
    private var createNotFoundHandler: CreateNotFoundItemHandler?
    private var items: [T]
    private var selectedItems: Binding<Set<T>>
    
    @State private var searchTerm: String = ""
    
    public init(
        items: [T],
        selectedItems: Binding<Set<T>>,
        createNotFoundHandler: CreateNotFoundItemHandler? = nil
    ) {
        self.items = items
        self.createNotFoundHandler = createNotFoundHandler
        self.selectedItems = selectedItems
    }
    
    public var body: some View {
        List {
            let exactSearchMatch = !self.filteredItems().map({ $0.getDisplayText().lowercased() }).contains(self.searchTerm.lowercased())
            let showCreateButton = (exactSearchMatch && self.searchTerm != "") && self.createNotFoundHandler != nil

            let favoriteItems = self.filteredItems().filter { $0.isFavorite() }
            let otherItems = self.filteredItems().filter { !$0.isFavorite() }

            if self.filteredItems().isEmpty && !showCreateButton {
                Text("No items")
            } else if favoriteItems.isEmpty {
                ForEach(otherItems) { item in
                    self.selectableItem(item: item)
                }
            } else {
                Section("Favorites") {
                    ForEach(favoriteItems) { item in
                        self.selectableItem(item: item)
                    }
                }
                if !otherItems.isEmpty {
                    Section("Other") {
                        ForEach(otherItems) { item in
                            self.selectableItem(item: item)
                        }
                    }
                }
            }
            
            if showCreateButton {
                Button(action: {
                    self.createNotFoundHandler?.createItem(text: self.searchTerm)
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                        Text("Create \(self.searchTerm)")
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .searchable(text: self.$searchTerm)
    }
    
    private func selectableItem(item: T) -> some View {
        SelectableListItemView(text: item.getDisplayText(), selected: self.selectedItems.wrappedValue.contains(item), tapHandler: {
            if self.selectedItems.wrappedValue.contains(item) {
                self.selectedItems.wrappedValue.remove(item)
            } else {
                self.selectedItems.wrappedValue.insert(item)
            }
        })
    }

    func filteredItems() -> [T] {
        if self.searchTerm == "" {
            return self.items
        }
        
        let searchTermLower = self.searchTerm.lowercased()
        
        return self.items
            .filter {
                return $0.getDisplayText()
                    .lowercased()
                    .contains(searchTermLower)
            }
    }
}


