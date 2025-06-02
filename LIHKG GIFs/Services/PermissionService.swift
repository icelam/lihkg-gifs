//
//  PermissionService.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 29/5/2025.
//

import Cocoa
import UserNotifications

class PermissionService: NSObject {
  @discardableResult
  static func aquireAccessibilityPriviledge(isPrompt: Bool) -> Bool {
    // Accessibility permission is required for paste command from macOS 10.14 Mojave.
    // For macOS 10.14 and later only, check accessibility permission at startup and paste
    guard #available(macOS 10.14, *) else { return true }

    let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let opts = [checkOptionPromptKey: isPrompt] as CFDictionary
    let enabled = AXIsProcessTrustedWithOptions(opts);
    NSLog("Accessibility permissions \(enabled ? "" : "not ")granted")
    return enabled
  }

  static func showRequireAccessibilityPriviledgeAlert() {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("ACCESSIBILITY_PERMISSION_REQUIRED_ALERT_TITLE", comment: "")
    alert.informativeText = NSLocalizedString("ACCESSIBILITY_PERMISSION_REQUIRED_ALERT_DESCRIPTION", comment: "")
    alert.addButton(withTitle: NSLocalizedString("ACCESSIBILITY_PERMISSION_REQUIRED_ALERT_BUTTON", comment: ""))
    NSApp.activate(ignoringOtherApps: true)

    if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
      guard !openAccessibilitySettingWindow() else { return }
      aquireAccessibilityPriviledge(isPrompt: true)
    }
  }

  static func openAccessibilitySettingWindow() -> Bool {
    guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return false }
    return NSWorkspace.shared.open(url)
  }
}
