//
//  FileManager.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import Cocoa

class FileManager: NSObject {
  // Get file url from bundle
  static func getBundleFile(fileName: String, fileType: String) -> URL? {
    if let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType) {
      return fileURL
    }
    
    return nil
  }
}
