//
//  StringFormatter.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//
// swiftlint:disable function_parameter_count
// swiftlint:disable cyclomatic_complexity

import Foundation

public class StringFormatter {
    public var decimalRegex: NSRegularExpression
    public var lowerAlphaRegex: NSRegularExpression
    public var upperAlphaRegex: NSRegularExpression

    public init() {
        guard let decimalRegex = try? NSRegularExpression(pattern: "[0-9]"),
              let lowerAlphaRegex = try? NSRegularExpression(pattern: "[a-z]"),
              let upperAlphaRegex = try? NSRegularExpression(pattern: "[A-Z]") else {
            fatalError("Could not create Regular Expression")
        }

        self.decimalRegex = decimalRegex
        self.lowerAlphaRegex = lowerAlphaRegex
        self.upperAlphaRegex = upperAlphaRegex
    }

    public func formatString(string: String, mask: String) -> String {
        var cursorPosition = 0
        return formatString(string: string, mask: mask, cursorPosition: &cursorPosition)
    }

    public func formatString(string: String, mask: String, cursorPosition: inout NSInteger) -> String {
        let matches = parts(ofMask: mask)
        var copyFromMask = true
        var appendRestOfMask = true
        var stringIndex = 0
        var result = ""

        for match in matches {
            let matchString =
                processMatch(match: match,
                             string: string,
                             stringIndex: &stringIndex,
                             mask: mask,
                             copyFromMask: &copyFromMask,
                             appendRestOfMask: &appendRestOfMask,
                             cursorPosition: &cursorPosition
                )
            result = result.appending(matchString)
        }

        return result
    }

    public func unformatString(string: String, mask: String) -> String {
        let maskedString = formatString(string: string, mask: mask)
        let matches = parts(ofMask: mask)
        var result = ""
        var skip = true
        var index = 0

        for match in matches {
            if match == "{{" {
                skip = false
            } else if match == "}}" {
                skip = true
            } else {
                let maxLength = maskedString.count - index
                let length = min(maxLength, match.count)
                if !skip {
                    let endIndex = index + length
                    let maskedStringFragment = maskedString[index..<endIndex]
                    result = result.appending(maskedStringFragment)
                }
                index += length
            }
        }

        return result
    }

    public func processMatch(
        match: String,
        string: String,
        stringIndex: inout Int,
        mask: String,
        copyFromMask: inout Bool,
        appendRestOfMask: inout Bool,
        cursorPosition: inout Int
    ) -> String {
        var result = ""

        if match.isEqual("{{") {
            copyFromMask = false
        } else if match.isEqual("}}") {
            copyFromMask = true
        } else {
            var maskIndex = 0

            while stringIndex < string.count && maskIndex < match.count {
                let stringChar = string[stringIndex..<(stringIndex + 1)]
                let maskChar = match[maskIndex..<(maskIndex + 1)]
                if copyFromMask {
                    result = result.appending(maskChar)
                    if stringChar.isEqual(maskChar) {
                        stringIndex += 1
                    } else {
                        if cursorPosition >= stringIndex {
                            cursorPosition += 1
                        }
                    }
                    maskIndex += 1
                } else {
                    let range = NSRange(location: 0, length: 1)
                    if maskChar.isEqual("9") && decimalRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("a") &&
                              lowerAlphaRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("A") &&
                              upperAlphaRegex.numberOfMatches(in: stringChar, range: range) > 0 {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    } else if maskChar.isEqual("*") {
                        result = result.appending(stringChar)
                        maskIndex += 1
                    }

                    stringIndex += 1
                }
            }

            if appendRestOfMask {
                if maskIndex < match.count {
                    if copyFromMask {
                        let remainingLength = match.count - maskIndex
                        let endIndex = maskIndex+remainingLength
                        result = result.appending(match[maskIndex..<endIndex])

                        if cursorPosition >= stringIndex {
                            cursorPosition += remainingLength
                        }
                    }

                    appendRestOfMask = false
                }
            }
        }

        return result
    }

    func parts(ofMask mask: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "\\{\\{|\\}\\}|([^\\{\\}]|\\{(?!\\{)|\\}(?!\\}))*") else {
            fatalError("Could not create Regular Expression")
        }

        let results = regex.matches(in: mask, range: NSRange(location: 0, length: mask.count))

        return results.map { (mask as NSString).substring(with: $0.range) }
    }

    public func relaxMask(mask: String) -> String {
        let matches = parts(ofMask: mask)
        var relaxedMask = mask
        var replaceCharacters = false
        var maskIndex = 0

        for match in matches {
            if match.isEqual("{{") {
                replaceCharacters = true
                maskIndex += 2
            } else if match.isEqual("}}") {
                replaceCharacters = false
                maskIndex += 2
            } else {
                var length = match.count
                while length > 0 {
                    if replaceCharacters {
                        let startIndex = relaxedMask.index(relaxedMask.startIndex, offsetBy: maskIndex)
                        let endIndex = relaxedMask.index(after: startIndex)
                        relaxedMask = relaxedMask.replacingCharacters(in: startIndex..<endIndex, with: "*")
                    }
                    maskIndex += 1
                    length -= 1
                }
            }
        }

        return relaxedMask
    }

}
