//
//  ContentView.swift
//  Unbplaces
//
//  Created by Turma02-7 on 23/06/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
            }
            .tabItem{
                Label("Mapa", systemImage: "map.circle")
            }
            
            CalendarioView()
                .tabItem{
                    Label("Calendário", systemImage: "calendar.circle")
                }
            
            ConfiguracoesView()
                .tabItem {
                    Label("Configurações", systemImage: "gear.circle" )
                }
            
            PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle.fill" )
                }
        }
    }
}

#Preview {
    SwiftUIView()
}
