//
//  CubesView.swift
//  HitStudio
//
//  Created by freegatik on 20.04.2023.
//

import SwiftUI

struct CubesView: View {
    var body: some View {
        ZStack {
            ForEach(0 ..< 10) {index in
                CubeSetView()
                    .offset(x: 100)
                    .rotationEffect(.degrees(Double(index) * 60 ))
                
            }
        }
    }
}

struct CubeSetView: View {
    @ObservedObject var viewModel = CubesViewModel()
    
    var body: some View {
        ZStack {
            ForEach(0..<viewModel.allCubes.count, id: \.self) {index in
                cubeView(index: index)
                
            }
        }
        .onAppear(perform: viewModel.startRotation)
    }
    
    private func cubeView(index: Int) -> some View {
        let offset = viewModel.allIndicies[index]
        return viewModel.allCubes[index].view
            .offset(x: offset.0, y: offset.1)
            .zIndex(offset.2)
    }
}
