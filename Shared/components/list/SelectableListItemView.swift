//
//  SelectableListItemView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct SelectableListItemView: View {
    var text: String
    @State var selected: Bool
    
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
            self.selected.toggle()
        }
    }
}

struct SelectableListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectableListItemView(text: "item-1", selected: true)
            SelectableListItemView(text: "item-2", selected: false)
        }
    }
}
