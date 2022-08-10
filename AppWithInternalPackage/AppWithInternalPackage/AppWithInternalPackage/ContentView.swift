//
//  ContentView.swift
//  AppWithInternalPackage
//
//  Created by Florent Morin on 10/08/2022.
//

import SwiftUI
import InternalLibrary

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                Hello(name: "Florent").printHello()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
