//
//  ContentView.swift
//  AstroSwift
//
//  Created by Dalton Claybrook on 6/6/21.
//

import SwiftUI

struct ContentView: View {
    let viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, world!")
            Button("Test SpaceKit", action: {
                async {
                    await viewModel.performSpaceKitTests()
                }
            })
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
