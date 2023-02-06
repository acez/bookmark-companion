//
//  SelectOrCreateList.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public protocol SelectOrCreateItemListProvider: Identifiable, Hashable {
    func getItemText() -> String
}

public struct SelectOrCreateList<T: SelectOrCreateItemListProvider>: View {
    private var items: [T]
    private var createActionHandler: (String) -> Void

    @State private var searchTerm: String = ""
    @Binding var selectedItems: Set<T>

    public init(items: [T], selectedItems: Binding<Set<T>>, createActionHandler: @escaping (String) -> Void) {
        self.items = items
        self.createActionHandler = createActionHandler
        self._selectedItems = selectedItems
    }
    
    public var body: some View {
        Form {
            if self.filteredItems().isEmpty {
                if  self.searchTerm == "" {
                    Text("No items")
                } else {
                    Button(action: {
                        self.createActionHandler(self.searchTerm)
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
            } else {
                List(self.filteredItems(), selection: self.$selectedItems) {
                    Text($0.getItemText())
                }
                .environment(\.editMode, .constant(EditMode.active))
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
                return $0.getItemText()
                    .lowercased()
                    .contains(searchTermLower)
            }
    }
}

struct SelectOrCreateList_Previews: PreviewProvider {
    struct Item: SelectOrCreateItemListProvider, Identifiable {
        var id: UUID
        var name: String
        
        func getItemText() -> String {
            return self.name
        }
    }
    
    static let itemList = [
        Item(id: UUID(), name: "item-1"),
        Item(id: UUID(), name: "item-2"),
        Item(id: UUID(), name: "item-3")
    ]
    
    @State static var selection: [Item] = []
    @State static var selectedItems: Set<Item> = [itemList[1]]
    
    static var previews: some View {
        NavigationView {
            SelectOrCreateList(
                items: self.itemList,
                selectedItems: self.$selectedItems,
                createActionHandler: {_ in}
            )
        }.previewDisplayName("with items")
        NavigationView {
            SelectOrCreateList<Item>(
                items: [],
                selectedItems: self.$selectedItems,
                createActionHandler: {_ in}
            )
        }.previewDisplayName("without items")
    }
}
