//
//  CommonListView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

protocol CreateNotFoundItemHandler {
    func createItem(text: String)
}

protocol CommonListItem: Hashable, Identifiable {
    func getDisplayText() -> String
}

struct CommonSelectListView<T: CommonListItem>: View {
    private var createNotFoundHandler: CreateNotFoundItemHandler?
    private var items: [T]
    private var selectedItems: Binding<Set<T>>
    
    public init(
        items: [T],
        selectedItems: Binding<Set<T>>,
        createNotFoundHandler: CreateNotFoundItemHandler? = nil
    ) {
        self.items = items
        self.createNotFoundHandler = createNotFoundHandler
        self.selectedItems = selectedItems
    }
    
    var body: some View {
        List(selection: self.selectedItems) {
            ForEach(self.items) { item in
                Text(item.getDisplayText())
            }
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
    
    static var testItems = [
        TestItem(id: UUID(), text: "test-1"),
        TestItem(id: UUID(), text: "test-2")
    ]
    
    @State static var selection: Set<TestItem> = [testItems[0]]
    
    static var previews: some View {
        CommonSelectListView(items: testItems, selectedItems: $selection)
    }
}
