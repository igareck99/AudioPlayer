//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Игорь Коноваленко on 07.07.2022.
//

import SwiftUI

@main
struct MusicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
