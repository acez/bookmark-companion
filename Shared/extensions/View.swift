//
//  ViewExtensions.swift
//  Created by Christian Wilhelm
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `conditionalModifier`<T>(_ condition: Bool, exec: (Self) -> T) -> some View where T: View {
        if condition {
            exec(self)
        } else {
            self
        }
    }
}
