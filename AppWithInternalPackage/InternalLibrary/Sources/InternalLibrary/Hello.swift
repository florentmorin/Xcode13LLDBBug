//
//  Hello.swift
//  
//
//  Created by Florent Morin on 10/08/2022.
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
