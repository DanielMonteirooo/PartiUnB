//
//  PartiUnBApp.swift
//  PartiUnB
//
//  Created by Turma02-7 on 26/06/25.
//

import SwiftUI

@main
struct PartiUnBApp: App {

    // Lê a mesma variável do AppStorage para aplicar o tema
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            SwiftUIView()
                // Aplica o esquema de cores escolhido em todo o app
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
