import Foundation
import UIKit

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red     = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green   = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue    = CGFloat((hex & 0xFF)) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }

    func lighter(amount amount: CGFloat) -> UIColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }

    private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor( hue: hue,
                saturation: saturation,
                brightness: brightness * amount,
                alpha: alpha )
        } else {
            return self
        }
    }
    
    static func gradientColor(green: Double, red: Double) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: 0.0, alpha: 1.0)
    }

}
