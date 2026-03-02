import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Collects device information for feature request submissions
enum DeviceInfoProvider {
    static func collect() -> DeviceInfoData {
        var info = DeviceInfoData()

        #if os(iOS) || os(tvOS)
        info.platform = "iOS"
        info.osVersion = UIDevice.current.systemVersion
        info.deviceModel = UIDevice.current.model
        info.deviceManufacturer = "Apple"

        let screen = UIScreen.main
        info.screenWidth = Int(screen.bounds.width * screen.scale)
        info.screenHeight = Int(screen.bounds.height * screen.scale)
        info.screenScale = Double(screen.scale)

        switch UIDevice.current.userInterfaceIdiom {
        case .phone: info.deviceType = "Phone"
        case .pad: info.deviceType = "Tablet"
        case .tv: info.deviceType = "TV"
        case .mac: info.deviceType = "Desktop"
        default: info.deviceType = "Unknown"
        }
        #elseif os(macOS)
        info.platform = "macOS"
        info.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        info.deviceType = "Desktop"
        info.deviceManufacturer = "Apple"
        if let screen = NSScreen.main {
            info.screenWidth = Int(screen.frame.width * screen.backingScaleFactor)
            info.screenHeight = Int(screen.frame.height * screen.backingScaleFactor)
            info.screenScale = Double(screen.backingScaleFactor)
        }
        #elseif os(watchOS)
        info.platform = "watchOS"
        info.deviceType = "Watch"
        info.deviceManufacturer = "Apple"
        #endif

        info.locale = Locale.current.identifier

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            info.appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            info.appBuild = build
        }

        return info
    }
}
