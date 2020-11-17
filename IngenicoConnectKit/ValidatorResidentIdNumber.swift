//
//  ValidatorResidentIdNumber.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 7/10/2020.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorResidentIdNumber: Validator {

    /**
     Validates a Chinese Resident ID Number.
        - Parameters:
            - Value: The ID to be verified, 15 to 18 characters long
            - PaymentRequest: The Payment request that the id is a part of
        - Important: The return value can be obtained by reading the errors array of this class
     */
    public override func validate(value: String, for: PaymentRequest) {
        errors.removeAll()

        if value.count == 15 {
            // We perform no checksum validation for IDs with a length of 15
            // These IDs are older and thus do not contain a checksum
            // We only check if the id is a valid Integer

            if Int(value) == nil {
                errors.append(ValidationErrorResidentId())
                return
            }
        } else if value.count == 18 {
            if !checkSumIsValid(for: value) {
                errors.append(ValidationErrorResidentId())
                return
            }
        } else {
            errors.append(ValidationErrorResidentId())
            return
        }
    }

    /**
    Validation according to ISO 7064 Standard, MOD 11-2
    The polynomial method is used to calculate the checksum
    - Parameters:
        - id: The id to be verified, a String consisting of 18 characters, which are all single digit Integers
     - Returns:
        - Bool: True if the checksum is valid
    */
    public func checkSumIsValid(for id: String) -> Bool {

        let mod = 11
        let n = id.count - 1 // -1 because the last digit is the checksum

        var sum = 0

        for i in 0...n - 1 {
            /*
            First calculate the weight with the formula: 2^(n - 1)
            Where n is the index of the character starting from the end of the String
            This means the last number in the id has the n = 1, and the second to last has n = 2
             */
            let weight = Int(pow(2, Double((n - i)))) % mod

            /*
             We then calculate the product by multiplying the weight with the character value.
             We add this product to the sum and repeat this for every integer in the id,
             except the last digit because this is the checksum.
             */
            sum += weight * (Int(id[i]) ?? 0)
        }

        let checkSum = (12 - (sum % mod)) % mod

        // If the checksum is 10, the character X is used instead.
        if checkSum == 10 {
            if id[n] == "X" {
                return true
            }
        } else if Int(id[n]) == checkSum {
            return true
        }

        return false
    }
}
