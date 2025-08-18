//
//  ContentView.swift
//  Lucky Eagle Gaming
//
//  Created by Dias Atudinov on 18.08.2025.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
        let s = GameScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        return s
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameView()
}
