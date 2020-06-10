//
//  Benchmarking.swift
//  MitraXBenchmark
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import MitraX
import XConcurrencyKit

func benchmark() -> String {
    let threads = 5
    let iterations = 10_000

    let bank = Bank()

    let benchmark = MutlithreadBenchmark()

    let tm = MultithreadMachExecutionPreservingTimeMeter()
//    let tm = MultithreadMachExecutionTimeMeter()

    benchmark.perform(
        threads: threads,
        runs: iterations,
        prepareArgs: { () -> (from: Int, to: Int, amount: Int) in
            let from = Int.random(in: 0..<bank.accounts.count)
            let to = (from + Int.random(in: 1..<bank.accounts.count)) % bank.accounts.count
            let amount = Int.random(in: -5...5)
            return (from: from, to: to, amount: amount)
        },
        subject: { args in
            if Int.random(in: 0..<100) <= 95 {
                bank.transfer(from: args.from, to: args.to, amount: args.amount)
            } else {
                let total = bank.report().reduce(0, +)
                precondition(total == Bank.accountCount * Bank.initialBalance)
            }
            NanoUtils.spinDelay(for: 0)
        },
        multithreadExecutionTimeMeter: tm,
        overheadAdjustment: { _ in
            NanoUtils.spinDelay(for: 0)
        }
    )
    #if CHECK_RACE_CONDITIONS
    assert(bank.raceDetector.noProblemDetected)
    #endif
//    var summaryTimeMeter = tm.mergedReport.generate()
//    summaryTimeMeter.reportInNanosecs = true
    let summary = tm.kMeansReport.generate()
    return "\(summary)"
}
