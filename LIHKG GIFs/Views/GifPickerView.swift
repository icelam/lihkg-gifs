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
    PasteboardManager.copyImageToPasteboard(fileName: fileName)
    
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
    let accessEnabled = AXIsProcessTrustedWithOptions(options)

    if accessEnabled {
      PasteboardManager.paste()
    } else {
      NSLog("Not enough permission to execute paste command")
      
      NotificationManager.send(
        title: "Unable to paste GIF",
        body: "The GIF image were loaded to clipboard, but we could not paste the GIF due to insufficient permission. Please make sure you have grant \"Accessability\" permission to this app by going to System Preferences > Security & Privacy > Priacy > Accessability > Check \"\(Constants.BUNDLE_NAME)\"."
      )
    }
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
                      print("Failed to load GIF image (\(error), \(error.localizedDescription))")
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
      
      HStack(spacing: 15) {
        IconButton(
          iconName: "Thumbnails/" + Constants.CAT_GIFS[0],
          action: {
            selectedCategory = 0
          }
        )
        
        IconButton(
          iconName: "Thumbnails/" + Constants.COW_GIFS[0],
          action: {
            selectedCategory = 1
          }
        )
        
        IconButton(
          iconName: "Thumbnails/" + Constants.DOG_GIFS[13],
          action: {
            selectedCategory = 2
          }
        )
        
        IconButton(
          iconName: "Thumbnails/" + Constants.MOUSE_GIFS[0],
          action: {
            selectedCategory = 3
          }
        )
        
        IconButton(
          iconName: "Thumbnails/" + Constants.PIG_GIFS[0],
          action: {
            selectedCategory = 4
          }
        )
        
        IconButton(
          iconName: "Thumbnails/" + Constants.TIGER_GIFS[0],
          action: {
            selectedCategory = 5
          }
        )
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
