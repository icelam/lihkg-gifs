//
//  ContentView.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 26/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct GifPickerView: View {
  @EnvironmentObject private var integration: GifPickerIntegrationService
  @State private var selectedCategory: Int = 0
  private var shouldAnimateGifs: Binding<Bool> {
    Binding {
      integration.shouldAnimateGifs
    } set: {
      integration.shouldAnimateGifs = $0
    }
  }
  
  // Copy GIF file to clipboard
  func copyImage(fileName: String) {
    PasteboardService.copyImageToPasteboard(fileName: fileName)
    PasteboardService.paste()
  }
  
  var body: some View {
    let viewWidth: CGFloat = Constants.POPOVER_WIDTH
    let viewHeight: CGFloat = Constants.POPOVER_HEIGHT
    let imageSize: CGFloat = 80
    
    VStack {
      Spacer()
        .frame(width: viewWidth, height: 10)
  
      Text(Constants.BUNDLE_NAME)
        .font(.headline)
      
      Divider()
      
      ScrollView {
        ScrollViewReader { reader in
          LazyVStack(alignment: .center) {
            let columns = [
              GridItem(.fixed(imageSize)),
              GridItem(.fixed(imageSize)),
              GridItem(.fixed(imageSize)),
            ]
            
            LazyVGrid(columns: columns) {
              ForEach(Constants.GIFS[selectedCategory].value.indices, id: \.self) { index in
                Button(action: {
                  NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                  copyImage(fileName: Constants.GIFS[selectedCategory].value[index])
                }) {
                  LazyReleaseableWebImage {
                    // If a gif image only has single frame, AnimatedImage will appears empty
                    // Workaround is to use convert command to make 2 frames by combining
                    // file_name1.gif and file_name.2.gif, which is a copy of file_name.gif
                    // using command: 
                    // convert -delay 20 -loop 0 file_name*.gif file_name_animated.gif
                    AnimatedImage(
                      url: FileManager.getBundleFile(fileName: Constants.GIFS[selectedCategory].value[index], fileType: "gif"),
                      isAnimating: shouldAnimateGifs
                    )
                    // Workaround for isAnimating not respecting binded value
                    // https://github.com/SDWebImage/SDWebImageSwiftUI/issues/114
                    // FIXME: remove onViewCreate and onViewUpdate when issue is fixed
                    .onViewCreate { view, _ in
                      let imageView = view as! SDAnimatedImageView
                      imageView.autoPlayAnimatedImage = false
                    }
                    .onViewUpdate { view, _ in
                      let imageView = view as! SDAnimatedImageView
                      imageView.autoPlayAnimatedImage = true
                    }
                    .purgeable(true)
                    .onFailure(perform: {error in
                      NSLog("Failed to load GIF image (\(error), \(error.localizedDescription))")
                    })
                    .resizable()
                  }
                  .aspectRatio(1/1, contentMode: .fit)
                  .scaledToFit()
                  .frame(width: imageSize, height: imageSize)
                }
                .frame(width: imageSize, height: imageSize)
                .buttonStyle(.plain)
                .id(index)
              }
            }
          }
          .frame(maxWidth: .infinity)
          .onChange(of: selectedCategory) { _ in
            // scroll to image button with id=0
            reader.scrollTo(0, anchor: .top)
          }
        }
      }
      
      Divider()
      
      HStack(spacing: 8) {
        ForEach(Constants.GIFS.indices, id: \.self) { index in
          IconButton(
            iconName: "Thumbnails/" +  Constants.GIFS[index].key,
            action: {
              selectedCategory = index
            }
          )
        }
      }
          
      Spacer()
        .frame(width: viewWidth, height: 10)
    }
    .frame(width: viewWidth, height: viewHeight)
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static let integration: GifPickerIntegrationService = GifPickerIntegrationService()
  
  static var previews: some View {
    GifPickerView().environmentObject(integration)
  }
}
#endif
