//
//  SelectOrCreateList.swift
//  Created by Christian Wilhelm
//

import SwiftUI

protocol ItemListProvider: Identifiable {
    func getItemText() -> String
}

struct SelectOrCreateList<MODEL: ItemListProvider>: View {
    var items: [MODEL]
    
    @State private var searchTerm: String = ""
    
    var body: some View {
        List(self.filteredItems()) {
            Text($0.getItemText())
        }
            .searchable(text: self.$searchTerm)
    }
    
    func filteredItems() -> [MODEL] {
        if self.searchTerm == "" {
            return self.items
        }
        
        return self.items
            .filter { $0.getItemText().contains(self.searchTerm) }
    }
}

struct SelectOrCreateList_Previews: PreviewProvider {
    struct Item: ItemListProvider, Identifiable {
        var id: UUID
        var name: String
        
        func getItemText() -> String {
            return self.name
        }
    }
    
    @State static var selection: [Item] = []
    
    static var previews: some View {
        SelectOrCreateList(
            items: [
                Item(id: UUID(), name: "item-1"),
                Item(id: UUID(), name: "item-2"),
                Item(id: UUID(), name: "item-3")
            ]
        )
    }
}
