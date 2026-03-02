import Foundation

/// Device information collected when creating a feature request
public struct DeviceInfoData: Codable, Sendable, Equatable {
    public var platform: String?
    public var osVersion: String?
    public var deviceModel: String?
    public var deviceManufacturer: String?
    public var deviceType: String?
    public var appVersion: String?
    public var appBuild: String?
    public var locale: String?
    public var screenWidth: Int?
    public var screenHeight: Int?
    public var screenScale: Double?

    public init(
        platform: String? = nil,
        osVersion: String? = nil,
        deviceModel: String? = nil,
        deviceManufacturer: String? = nil,
        deviceType: String? = nil,
        appVersion: String? = nil,
        appBuild: String? = nil,
        locale: String? = nil,
        screenWidth: Int? = nil,
        screenHeight: Int? = nil,
        screenScale: Double? = nil
    ) {
        self.platform = platform
        self.osVersion = osVersion
        self.deviceModel = deviceModel
        self.deviceManufacturer = deviceManufacturer
        self.deviceType = deviceType
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.screenScale = screenScale
    }
}
