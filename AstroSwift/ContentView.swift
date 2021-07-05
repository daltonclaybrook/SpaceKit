//
//  ContentView.swift
//  AstroSwift
//
//  Created by Dalton Claybrook on 6/6/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    var viewModel = ContentViewModel()

    var body: some View {
        SolarSystemView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
