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
        Text("Hello, world!")
            .padding()
            .onAppear {
                viewModel.performSpaceKitTests()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
