//
// ErrorView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct ErrorView: View {
    private var title: String
    private var message: String
    private var details: String?

    public init(title: String, message: String, details: String? = nil) {
        self.title = title
        self.message = message
        self.details = details
    }
    
    public var body: some View {
        VStack {
            Section() {
                VStack {
                    Text(self.title)
                        .foregroundColor(.red)
                        .bold()
                    VStack(alignment: .leading) {
                        Text(self.message)
                            .textSelection(.enabled)
                        if self.details != nil {
                            Text(self.details!)
                                .fontWeight(.light)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ErrorView(title: "Error Title", message: "Error Message with some more information that can be a bit detailed.")
        }
        Form {
            ErrorView(title: "Error Title", message: "Error Message with some more information that can be a bit detailed.", details: "Some very detailed information about the error. That could possibility be a very long output from a backend request.")
        }
    }
}
