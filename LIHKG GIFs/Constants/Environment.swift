//
//  Environment.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import SwiftUI

enum AppEnvironment {
  case Debug
  case TestFlight
  case AppStore
}

struct Environment {
  // Set to private for internal use only, external use should access `appEnvironment`
  private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  
  // Require "Build Setting > Apple Clang - Preprocessing > Preprocessor Macroos > Debug" set to "DEBUG=1"
  static var isDebug: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }

  static var appEnvironment: AppEnvironment {
    if isDebug {
      return .Debug
    } else if isTestFlight {
      return .TestFlight
    } else {
      return .AppStore
    }
  }
}
