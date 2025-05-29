//
//  PasteboardService.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import Cocoa
import Carbon.HIToolbox

class PasteboardService: NSObject {
  static func copyImageToPasteboard(fileName: String) {
    let imageURL = FileManager.getBundleFile(fileName: fileName, fileType: "gif")
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.declareTypes([NSPasteboard.PasteboardType.fileURL], owner: nil)
    pasteBoard.writeObjects([imageURL! as any NSPasteboardWriting])
  }
  
  static func paste() {
    // Require Accessibility Permission
    guard PermissionService.aquireAccessibilityPriviledge(isPrompt: false) else {
      PermissionService.showRequireAccessibilityPriviledgeAlert()
      return
    }
    
    let vKeyCode = CGKeyCode(kVK_ANSI_V)
    DispatchQueue.main.async {
      let source = CGEventSource(stateID: .combinedSessionState)
      // Disable local keyboard events while pasting
      source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
      // Press Command + V
      let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
      keyVDown?.flags = .maskCommand
      // Release Command + V
      let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
      keyVUp?.flags = .maskCommand
      // Post Paste Command
      keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
      keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
  }
}
