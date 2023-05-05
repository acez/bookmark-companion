//
//  SelectableListItemView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct SelectableListItemView: View {
    var text: String
    var selected: Bool
    var tapHandler: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            if self.selected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.tapHandler()
        }
    }
}

struct SelectableListItemView_Previews: PreviewProvider {
    @State static var item1Selected: Bool = true
    @State static var item2Selected: Bool = false
    
    static var previews: some View {
        List {
            SelectableListItemView(text: "item-1", selected: item1Selected, tapHandler: {
                item1Selected.toggle()
            })
            SelectableListItemView(text: "item-2", selected: item2Selected, tapHandler: {
                item2Selected.toggle()
            })
        }
    }
}
