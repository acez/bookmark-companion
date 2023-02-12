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
            ForEach(self.items) { item in
                SelectableListItemView(text: item.getDisplayText(), selected: self.selectedItems.wrappedValue.contains(item), tapHandler: {
                    if self.selectedItems.wrappedValue.contains(item) {
                        self.selectedItems.wrappedValue.remove(item)
                    } else {
                        self.selectedItems.wrappedValue.insert(item)
                    }
                })
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
        TestItem(id: UUID(), text: "test-2"),
        TestItem(id: UUID(), text: "test-3")
    ]
    
    @State static var selection: Set<TestItem> = [testItems[0]]
    
    static var previews: some View {
        CommonSelectListView(items: testItems, selectedItems: $selection)
    }
}
