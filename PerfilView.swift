//
//  PerfilView.swift
//  PerfilView
//
//  Created by Turma02-10 on 23/06/25.
//

import SwiftUI

struct PerfilView: View {
    var body: some View {
        VStack {
            Image("Honestino").clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .padding()
                List {
                    Text("Nome: Honestino Guimarães")
                    Text("Email: honestino@aluno.unb.br")
                    Text("Matricula: 63019865")
                }
        }
    }
}

#Preview {
    PerfilView()
}
