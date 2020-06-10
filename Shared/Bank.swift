//
//  Bank.swift
//  MitraXBenchmark
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import MitraX
import XConcurrencyKit

/// Bank.
struct Bank {
    static let accountCount = 5
    static let initialBalance = 50

    let sharedManager: SharedManager

    #if CHECK_RACE_CONDITIONS
    let raceDetector = RaceSensitiveSection()
    #endif

    // MARK: - Properties (State)
    let accounts: [Property<Int>]

    // MARK: - Initialization

    init() {
        sharedManager = SharedManager()
        var acnts: [Property<Int>] = []
        for _ in 0..<Bank.accountCount {
            acnts.append(Property(value: Bank.initialBalance, sharedManager: sharedManager))
        }
        self.accounts = acnts
    }

    // MARK: - Commands

    func transfer(from fromAccount: Int, to toAccount: Int, amount: Int) {
        precondition(accounts.indices ~= fromAccount)
        precondition(accounts.indices ~= toAccount)
        sharedManager.borrow(
            accounts[fromAccount].rw,
            accounts[toAccount].rw)
        { from, to in
            // Note: races for non-overlapping fromAccount->toAccount pairs are allowed!
            #if CHECK_RACE_CONDITIONS
            raceDetector.exclusiveCriticalSection({
                from.value -= amount
                to.value += amount
            }, register: {
                $0(fromAccount)
                $0(toAccount)
            })
            #else
            from.value -= amount
            to.value += amount
            #endif
        }
    }

    // MARK: - Queries

    func report() -> [Int] {
        sharedManager.borrow(accounts[0].ro, accounts[1].ro, accounts[2].ro, accounts[3].ro, accounts[4].ro) { a0, a1, a2, a3, a4 in
            #if CHECK_RACE_CONDITIONS
            raceDetector.nonExclusiveCriticalSection({
                return [a0.value, a1.value, a2.value, a3.value, a4.value]
            }, register: { register in
                accounts.indices.forEach { register($0) }
            })
            #else
            return [a0.value, a1.value, a2.value, a3.value, a4.value]
            #endif
        }
    }
}
