import Foundation

private extension String {
    var wholeRange: NSRange {
        return NSRange(location: 0, length: characters.count)
    }

    //TODO: Use ObjectiveCBridgeable or wait until NSRegularExpression has a swifty API
    var _ns: NSString {
        return self as NSString
    }

    func substringWithRange(range: NSRange) -> String {
        return self._ns.substring(with: range)
    }
}

private extension TextCheckingResult {
    var ranges: [NSRange] {
        var ranges = [NSRange]()
        for i in 0 ..< numberOfRanges {
            ranges.append(range(at: i))
        }
        return ranges
    }
}

public struct Match {
    let matchedString: String
    let captureGroups: [String]

    init(baseString string: String, checkingResult: TextCheckingResult) {
        matchedString = string.substringWithRange(range: checkingResult.range)
        captureGroups = checkingResult.ranges.dropFirst().map {
            string.substringWithRange(range: $0)
        }
    }
}

public struct Regex {
    let pattern: String
    let options: RegularExpression.Options

    private let matcher: RegularExpression

    init?(pattern: String, options: RegularExpression.Options = []) {
        guard let matcher = try? RegularExpression(pattern: pattern, options: options) else {
            return nil
        }

        self.matcher = matcher
        self.pattern = pattern
        self.options = options
    }

    func match(string: String, options: RegularExpression.MatchingOptions = [], range: NSRange? = .none) -> Bool {
        let range = range ?? string.wholeRange

        return matcher.numberOfMatches(in: string, options: options, range: range) != 0
    }

    func matches(string: String, options: RegularExpression.MatchingOptions = [], range: NSRange? = .none) -> [Match] {
        let range = range ?? string.wholeRange

        return matcher.matches(in: string, options: options, range: range).map { Match(baseString: string, checkingResult: $0)
        }
    }
}
