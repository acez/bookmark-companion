//
//  ConfigurationButton.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public struct ConfigurationButton: View {
    var actionHandler: () -> Void
    
    public init(actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
    }
    
    public var body: some View {
        Button(action: {
            self.actionHandler()
        }, label: {
            Image(systemName: "gear")
        })

    }
}

struct ConfigurationButton_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationButton(actionHandler: {})
    }
}
