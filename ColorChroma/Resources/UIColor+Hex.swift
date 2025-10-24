// Shared/Extensions/UIColor+Hex.swift

import UIKit

extension UIColor {
    /// Converts a UIColor to its hexadecimal string representation (e.g., "#RRGGBB").
    /// - Returns: A string like "#FFFFFF" or nil if the color components can't be read.
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Use getRed(_:green:blue:alpha:) to extract the RGBA components.
        // This function returns `true` if it succeeds, `false` otherwise.
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            // If the color can't be converted to RGBA (e.g., it's a pattern color),
            // we can return nil or a default value.
            return nil
        }
        
        // Convert the float components (0.0-1.0) to integer values (0-255)
        let r = Int(red * 255.0)
        let g = Int(green * 255.0)
        let b = Int(blue * 255.0)
        
        // Format the integers into a hex string.
        // "%02lX" formats an integer as a 2-digit, uppercase hexadecimal number.
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
