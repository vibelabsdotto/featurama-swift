import SwiftUI

/// Theme colors used throughout the Featurama UI.
///
/// Pass a partial override to `FeaturamaView(theme:)` to customise individual colors
/// while keeping the rest auto-generated from `accentColor` + `colorScheme`.
///
/// ```swift
/// FeaturamaView(
///     accentColor: .mint,
///     theme: FeaturamaThemeOverrides(background: Color(hex: "#1a1a2e"))
/// )
/// ```
public struct FeaturamaTheme {
    public let background: Color
    public let card: Color
    public let secondary: Color
    public let text: Color
    public let textSecondary: Color
    public let accent: Color
    public let accentLight: Color
    public let accentForeground: Color
    public let border: Color
    public let borderAccent: Color
    public let gray100: Color
    public let warning: Color
    public let warningLight: Color
    public let warningText: Color

    func applying(_ overrides: FeaturamaThemeOverrides?) -> FeaturamaTheme {
        guard let o = overrides else { return self }
        return FeaturamaTheme(
            background: o.background ?? background,
            card: o.card ?? card,
            secondary: o.secondary ?? secondary,
            text: o.text ?? text,
            textSecondary: o.textSecondary ?? textSecondary,
            accent: o.accent ?? accent,
            accentLight: o.accentLight ?? accentLight,
            accentForeground: o.accentForeground ?? accentForeground,
            border: o.border ?? border,
            borderAccent: o.borderAccent ?? borderAccent,
            gray100: o.gray100 ?? gray100,
            warning: o.warning ?? warning,
            warningLight: o.warningLight ?? warningLight,
            warningText: o.warningText ?? warningText
        )
    }
}

/// Partial theme overrides. Only the colors you set will replace the auto-generated values.
public struct FeaturamaThemeOverrides {
    public var background: Color?
    public var card: Color?
    public var secondary: Color?
    public var text: Color?
    public var textSecondary: Color?
    public var accent: Color?
    public var accentLight: Color?
    public var accentForeground: Color?
    public var border: Color?
    public var borderAccent: Color?
    public var gray100: Color?
    public var warning: Color?
    public var warningLight: Color?
    public var warningText: Color?

    public init(
        background: Color? = nil,
        card: Color? = nil,
        secondary: Color? = nil,
        text: Color? = nil,
        textSecondary: Color? = nil,
        accent: Color? = nil,
        accentLight: Color? = nil,
        accentForeground: Color? = nil,
        border: Color? = nil,
        borderAccent: Color? = nil,
        gray100: Color? = nil,
        warning: Color? = nil,
        warningLight: Color? = nil,
        warningText: Color? = nil
    ) {
        self.background = background
        self.card = card
        self.secondary = secondary
        self.text = text
        self.textSecondary = textSecondary
        self.accent = accent
        self.accentLight = accentLight
        self.accentForeground = accentForeground
        self.border = border
        self.borderAccent = borderAccent
        self.gray100 = gray100
        self.warning = warning
        self.warningLight = warningLight
        self.warningText = warningText
    }
}
