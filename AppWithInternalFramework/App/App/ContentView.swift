//
//  ContentView.swift
//  App
//
//  Created by Florent Morin on 19/07/2022.
//

import SwiftUI
import InternalFramework

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
