//
//  LEGSpriteViewContainer.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI
import SpriteKit


struct LEGSpriteViewContainer: UIViewRepresentable {
    @StateObject var user = LEGUser.shared
    var scene: LEGGameScene
    @Binding var gameWin: Bool?
    @Binding var showRepOverlay: Bool
    @Binding var repNum: Int
    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .clear
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        scene.victoryHandler = { isWin in
            DispatchQueue.main.async {
                gameWin = isWin
            }
            if isWin {
                user.updateUserMoney(for: 200)
            }
        }
        
        scene.repsSpawnHandler = { showRepOverlay, repNum in
            self.showRepOverlay = showRepOverlay
            self.repNum = repNum
        }
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.frame = UIScreen.main.bounds
    }
}
