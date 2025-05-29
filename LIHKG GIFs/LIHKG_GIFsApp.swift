//
//  LIHKG_GIFsApp.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 26/10/2022.
//

import SwiftUI
import SDWebImage

@main
struct LIHKG_GIFsApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
  // Unused scene - this is a menu bar app
  var body: some Scene {
    Settings { }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSPopoverDelegate {
  var bundleShortVersionString = Constants.BUNDLE_VERSION
  let bundleName = Constants.BUNDLE_NAME
  
  var statusItem: NSStatusItem!
  let statusMenu = NSMenu()
  let popover = NSPopover()
  
  let integration = GifPickerIntegrationService()
  
  // Opens menu on right click of status item and popover on left click
  @objc func handleButtonClick(sender: AnyObject) {
    guard let event = NSApp.currentEvent else { return }
    
    if event.type == NSEvent.EventType.rightMouseUp {      
      statusItem.menu = statusMenu
      statusItem.button?.performClick(nil)
    } else {
      if popover.isShown {
        popover.performClose(sender)
      } else {
        if let button = statusItem.button {
          popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: NSRectEdge.minY
          )
          
          // Close popover when click on non-popover areas
          // Must work together with NSPopover.Behavior.transient
          popover.contentViewController?.view.window?.makeKey()
        }
      }
    }
  }
  
  // Construct status item button
  func constructStatusItemButton() {
    statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    if let button = statusItem.button {
      button.image = NSImage(named:NSImage.Name("StatusBarIcon"))
      button.action = #selector(self.handleButtonClick(sender:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
  }
  
  // construct status menu
  func constructStatusMenu() {
    statusMenu.addItem(
      NSMenuItem(
        title: Environment.isDebug ? "\(bundleName) (Development)" : "\(bundleName) (v\(bundleShortVersionString))",
        action: nil,
        keyEquivalent: ""
      )
    )
    statusMenu.addItem(NSMenuItem.separator())
    statusMenu.addItem(
      NSMenuItem(
        title: NSLocalizedString("QUIT", comment: ""),
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
      )
    )
    
    statusMenu.delegate = self
  }
  
  // Application starts
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Request Accessibility Permission
    PermissionService.aquireAccessibilityPriviledge(isPrompt: true)
    
    constructStatusItemButton()
    constructStatusMenu()
    
    // Construct popover
    popover.delegate = self
    popover.behavior = NSPopover.Behavior.transient
    popover.contentViewController = GifPickerViewController(integration)
    popover.contentSize = NSSize(width: Constants.POPOVER_WIDTH, height: Constants.POPOVER_HEIGHT)
  }
  
  // Release memory and clear any image cache to prevent loading of an old version GIF
  func clearImageCache() {
    SDImageCache.shared.clearMemory()
    SDImageCache.shared.clearDisk()
  }
  
  // Applicatio closes
  func applicationWillTerminate(_ notification: Notification) {
    clearImageCache()
  }
  
  // Unregister menu to prevent opening on left click
  func menuDidClose(_ menu: NSMenu) {
    statusItem.menu = nil
  }
  
  // Stop GIF animation inside popover to reduce CPU and memory using
  func popoverWillClose(_ notification: Notification) {
    integration.shouldAnimateGifs = false
  }
  
  // Start GIF animation inside popover
  func popoverWillShow(_ notification: Notification) {
    integration.shouldAnimateGifs = true
  }
}
