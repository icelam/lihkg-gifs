//
//  AppDelegate.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 26/10/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  let bundleName = (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ?? ""
  
  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
  let statusMenu = NSMenu()
  let popover = NSPopover()
  
  // Copy GIF file to clipboard
  @objc func copyImage(_ sender: NSMenuItem?) {
    PasteboardManager.copyImageToPasteboard(fileName: sender!.title)
  }
  
  // Construct status item button
  func constructStatusItemButton() {
    if let button = statusItem.button {
      button.image = NSImage(named:NSImage.Name("StatusBarIcon"))
    }
  }
  
  // Construct status menu
  func constructStatusMenu() {
    statusMenu.addItem(
      NSMenuItem(
        title: bundleName + " (v" + bundleShortVersionString! + ")",
        action: nil,
        keyEquivalent: ""
      )
    )
    statusMenu.addItem(NSMenuItem.separator())
    for (categoryName, imageIdentifierList) in Constants.GIFS  {
      let categorySubMenu = NSMenu()
      let categoryMenuItem = NSMenuItem(title: categoryName, action: nil, keyEquivalent: "")
      
      for imageIdentifier in imageIdentifierList {
        let subMenuItem = NSMenuItem(title: imageIdentifier, action: #selector(self.copyImage(_:)), keyEquivalent: "")
        if let subMenuItemIcon = NSImage(named: NSImage.Name("Thumbnails/" + imageIdentifier)) {
          subMenuItem.image = subMenuItemIcon
        }
        categorySubMenu.addItem(subMenuItem)
      }
      
      statusMenu.setSubmenu(categorySubMenu, for: categoryMenuItem)
      statusMenu.addItem(categoryMenuItem)
    }
    statusMenu.addItem(NSMenuItem.separator())
    statusMenu.addItem(
      NSMenuItem(
        title: "Quit",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
      )
    )
    
    statusItem.menu = statusMenu
  }
  
  // Application starts
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    constructStatusItemButton()
    constructStatusMenu()
  }
}
