//
//  SelectOrCreateList.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public protocol SelectOrCreateItemListProvider: Identifiable, Hashable {
    func getItemText() -> String
}

public struct SelectOrCreateList<T: SelectOrCreateItemListProvider, I: Hashable>: View {
    private var items: [T]
    private var createActionHandler: (String) -> Void

    @State private var searchTerm: String = ""
    @Binding var selectedItems: Set<I>
    
    public init(items: [T], selectedItems: Binding<Set<I>>, createActionHandler: @escaping (String) -> Void) {
        self.items = items
        self.createActionHandler = createActionHandler
        self._selectedItems = selectedItems
    }
    
    public var body: some View {
        List(selection: self.$selectedItems) {
            if self.filteredItems().isEmpty {
                if  self.searchTerm == "" {
                    Text("No items")
                } else {
                    Button(action: {
                        self.createActionHandler(self.searchTerm)
                        self.searchTerm = ""
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
                ForEach(self.filteredItems()) {
                    Text($0.getItemText())
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(EditMode.active))
        .searchable(text: self.$searchTerm, placement: .toolbar)
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
    @State static var selectedItems: Set<UUID> = [itemList[1].id]
    
    static var previews: some View {
        NavigationView {
            SelectOrCreateList(
                items: self.itemList,
                selectedItems: self.$selectedItems,
                createActionHandler: {_ in}
            )
            .navigationTitle("Dummy Title")
        }
        .previewDisplayName("with items")
        NavigationView {
            SelectOrCreateList<Item, UUID>(
                items: [],
                selectedItems: self.$selectedItems,
                createActionHandler: {_ in}
            )
            .navigationTitle("Dummy Title")
        }.previewDisplayName("without items")
    }
}
