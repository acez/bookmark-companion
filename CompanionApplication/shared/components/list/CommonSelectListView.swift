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

            if self.filteredItems().isEmpty && !showCreateButton {
                Text("No items")
            } else {
                ForEach(self.filteredItems()) { item in
                    SelectableListItemView(text: item.getDisplayText(), selected: self.selectedItems.wrappedValue.contains(item), tapHandler: {
                        if self.selectedItems.wrappedValue.contains(item) {
                            self.selectedItems.wrappedValue.remove(item)
                        } else {
                            self.selectedItems.wrappedValue.insert(item)
                        }
                    })
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

struct CommonListView_Previews: PreviewProvider {
    struct TestItem: CommonListItem {
        var id: UUID
        var text: String
        func getDisplayText() -> String {
            return self.text
        }
    }
    
    struct TestHandler: CreateNotFoundItemHandler {
        func createItem(text: String) {
        }
    }
    
    static var testItems = [
        TestItem(id: UUID(), text: "test-1"),
        TestItem(id: UUID(), text: "test-2"),
        TestItem(id: UUID(), text: "test-3")
    ]
    
    @State static var selection: Set<TestItem> = [testItems[0]]
    
    static var previews: some View {
        NavigationView {
            CommonSelectListView(items: testItems, selectedItems: $selection)
        }.previewDisplayName("without create handler")
        NavigationView {
            CommonSelectListView(items: testItems, selectedItems: $selection, createNotFoundHandler: TestHandler())
        }.previewDisplayName("with create handler")
    }
}
