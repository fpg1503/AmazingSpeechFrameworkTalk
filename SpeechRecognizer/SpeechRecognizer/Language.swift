import Foundation

enum Language: String {
    case portuguese = "pt-BR"
    case english = "en-US"

    var locale: Locale {
        return Locale(localeIdentifier: rawValue)
    }
}
