import SwiftUI

enum ThemeFactory {
    static func create(accentColor: Color, colorScheme: ColorScheme) -> FeaturamaTheme {
        let components = accentColor.hslComponents
        let h = components.h
        let s = components.s
        let isDark = colorScheme == .dark

        let accentLight: Color = isDark
            ? Color(hue: h / 360, saturation: min(s, 30) / 100, brightness: 0.25)
            : Color(hue: h / 360, saturation: min(s, 40) / 100, brightness: 0.96)

        let luminance = accentColor.relativeLuminance
        let accentForeground: Color = luminance > 0.4 ? .black : .white

        if isDark {
            return FeaturamaTheme(
                background: Color(red: 0, green: 0, blue: 0),
                card: Color(red: 0.11, green: 0.11, blue: 0.118),
                secondary: Color(red: 0.173, green: 0.173, blue: 0.18),
                text: .white,
                textSecondary: Color(red: 0.557, green: 0.557, blue: 0.576),
                accent: accentColor,
                accentLight: accentLight,
                accentForeground: accentForeground,
                border: Color(red: 0.22, green: 0.22, blue: 0.227),
                borderAccent: accentColor,
                gray100: Color(red: 0.11, green: 0.11, blue: 0.118),
                warning: Color(red: 0.961, green: 0.620, blue: 0.043),
                warningLight: Color(red: 0.259, green: 0.125, blue: 0.024),
                warningText: Color(red: 0.988, green: 0.827, blue: 0.302)
            )
        }

        return FeaturamaTheme(
            background: Color(red: 0.949, green: 0.949, blue: 0.969),
            card: .white,
            secondary: Color(red: 0.949, green: 0.949, blue: 0.969),
            text: .black,
            textSecondary: Color(red: 0.557, green: 0.557, blue: 0.576),
            accent: accentColor,
            accentLight: accentLight,
            accentForeground: accentForeground,
            border: Color(red: 0.898, green: 0.898, blue: 0.918),
            borderAccent: accentColor,
            gray100: Color(red: 0.898, green: 0.898, blue: 0.918),
            warning: Color(red: 0.961, green: 0.620, blue: 0.043),
            warningLight: Color(red: 0.996, green: 0.953, blue: 0.780),
            warningText: Color(red: 0.573, green: 0.251, blue: 0.055)
        )
    }
}

// MARK: - Color Extensions

extension Color {
    struct HSLComponents {
        let h: Double
        let s: Double
        let l: Double
    }

    var hslComponents: HSLComponents {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif canImport(AppKit)
        NSColor(self).usingColorSpace(.sRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif

        let cMax = max(r, max(g, b))
        let cMin = min(r, min(g, b))
        var h: Double = 0
        var s: Double = 0
        let l = Double(cMax + cMin) / 2

        if cMax != cMin {
            let d = Double(cMax - cMin)
            s = l > 0.5 ? d / (2 - Double(cMax) - Double(cMin)) : d / (Double(cMax) + Double(cMin))
            switch cMax {
            case r:
                h = (Double(g - b) / d + (g < b ? 6 : 0)) / 6
            case g:
                h = (Double(b - r) / d + 2) / 6
            default:
                h = (Double(r - g) / d + 4) / 6
            }
        }

        return HSLComponents(h: h * 360, s: s * 100, l: l * 100)
    }

    var relativeLuminance: Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif canImport(AppKit)
        NSColor(self).usingColorSpace(.sRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif

        func channel(_ v: CGFloat) -> Double {
            let s = Double(v)
            return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }
}
