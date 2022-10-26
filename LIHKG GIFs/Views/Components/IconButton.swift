//
//  IconButton.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import SwiftUI

struct IconButton: View {
  var iconName: String
  var action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(iconName).renderingMode(.original)
    }
    .buttonStyle(.plain)
    .controlSize(.large)
  }
}
