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
        ZStack {
            PlanetEllipseView(
                ellipseSize: ellipseSize,
                planetSize: 20,
                angle: viewModel.angle
            )
            Text("\(Int(viewModel.angle.degrees))°")
        }
        .onAppear { viewModel.startIncrementingAngle() }
    }

    private var ellipseSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(
            width: screenSize.width - 20,
            height: (screenSize.width - 20) * viewModel.ellipseHeightMultiplier
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
