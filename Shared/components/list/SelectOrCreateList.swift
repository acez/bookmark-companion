//
//  SelectOrCreateList.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public protocol SelectOrCreateItemListProvider: Identifiable {
    func getItemText() -> String
}

public struct SelectOrCreateList<MODEL: SelectOrCreateItemListProvider>: View {
    private var items: [MODEL]
    private var createActionHandler: (String) -> Void

    @State private var searchTerm: String = ""

    public init(items: [MODEL], createActionHandler: @escaping (String) -> Void) {
        self.items = items
        self.createActionHandler = createActionHandler
    }
    
    public var body: some View {
        List {
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
                ForEach(self.filteredItems()) {
                    Text($0.getItemText())
                }
            }
        }
        .searchable(text: self.$searchTerm)
    }
    
    func filteredItems() -> [MODEL] {
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
    
    @State static var selection: [Item] = []
    
    static var previews: some View {
        NavigationView {
            SelectOrCreateList(
                items: [
                    Item(id: UUID(), name: "item-1"),
                    Item(id: UUID(), name: "item-2"),
                    Item(id: UUID(), name: "item-3")
                ],
                createActionHandler: {_ in}
            )
        }.previewDisplayName("with items")
        NavigationView {
            SelectOrCreateList<Item>(
                items: [],
                createActionHandler: {_ in}
            )
        }.previewDisplayName("without items")
    }
}
