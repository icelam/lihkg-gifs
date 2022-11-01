//
//  LazyReleaseableWebImage.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 28/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI

// Workaround for memory issue on SDWebImageSwiftUI
// https://github.com/SDWebImage/SDWebImageSwiftUI/issues/172#issuecomment-797703934
public struct LazyReleaseableWebImage: View {
  @State private var shouldShowImage: Bool = false
  private let content: () -> AnimatedImage
  
  public init(
    @ViewBuilder content: @escaping () -> AnimatedImage
  ) {
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      if shouldShowImage {
        content()
      }
    }
    .onAppear {
      shouldShowImage = true
    }
    .onDisappear {
      shouldShowImage = false
    }
  }
}
