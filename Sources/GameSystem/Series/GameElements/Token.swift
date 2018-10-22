//
//  Token.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Token on the galaxy map
enum Token: Equatable, Hashable {
    /// Star token
    case star
    /// Black Hole token
    case blackHole
    /// Destroyed by Black Hole token
    case destroyed
    /// Output token
    case outpost
    /// Company token
    case company(Int)
    /// A number correlating with playable coordinate options.
    case marker(Int)
}

extension Token {
    /// Extracts company id from self.
    /// - returns: Company ID or nil if token is not a company.
    var companyID: Int? {
        guard case let .company(companyID) = self else { return nil }
        return companyID
    }
}

extension Token: LosslessStringConvertible {
    var description: String {
        switch self {
        case .star: return "*"
        case .blackHole: return "@"
        case .destroyed: return " "
        case .outpost: return "+"
        case let .company(companyID):
            let letterA = UInt8(65)
            return String(UnicodeScalar(letterA + UInt8(companyID)))

        case let .marker(marker):
            let number1 = UInt8(49)
            return String(UnicodeScalar(number1 + UInt8(marker)))
        }
    }

    init?(_ description: String) {
        if description.count != 1 {
            return nil
        }

        switch description.first! {
        case "+": self = .outpost
        case "@": self = .blackHole
        case " ": self = .destroyed
        case "*": self = .star
        default:
            let uint8Value = description.utf8.map { UInt8($0) }.first!
            let number1 = UInt8(49)
            let letterA = UInt8(65)
            let numbers = (number1 ..< number1 + UInt8(9)).map { $0 }
            let letters = (letterA ..< letterA + UInt8(25)).map { $0 }
            if numbers.contains(uint8Value) {
                self = .marker(Int(uint8Value - number1))
            } else if letters.contains(uint8Value) {
                self = .company(Int(uint8Value - letterA))
            } else {
                return nil
            }
        }
    }
}

extension Token {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Token(string)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
}
