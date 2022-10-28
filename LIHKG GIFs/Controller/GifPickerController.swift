//
//  GifPickerController.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 28/10/2022.
//

import SwiftUI

class GifPickerIntegrationService: ObservableObject {
  @Published var shouldAnimateGifs: Bool = false
}

class GifPickerViewController: NSHostingController<AnyView> {
  init(_ integration: GifPickerIntegrationService) {
    super.init(rootView: AnyView(GifPickerView().environmentObject(integration)))
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
