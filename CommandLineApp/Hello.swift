//
//  Hello.swift
//  InternalFramework
//
//  Created by Florent Morin on 19/07/2022.
//

import Foundation

public final class Hello {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func printHello() {
        print("Hello \(name)!")
    }
}
