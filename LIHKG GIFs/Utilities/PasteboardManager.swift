//
//  PasteboardManager.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import Cocoa

class PasteboardManager: NSObject {
  static func copyImageToPasteboard(fileName: String) {
    let imageURL = FileManager.getBundleFile(fileName: fileName, fileType: "gif")
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.declareTypes([NSPasteboard.PasteboardType.fileURL], owner: nil)
    pasteBoard.writeObjects([imageURL! as any NSPasteboardWriting])
  }
}
