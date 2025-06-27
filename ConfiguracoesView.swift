import SwiftUI

struct ConfiguracoesView: View {
    // Usa AppStorage para salvar a configuração do modo escuro
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Configurações")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                List {
                    // Toggle para ativar/desativar o Modo Escuro
                    Toggle(isOn: $isDarkMode) {
                        Text("Modo Escuro")
                    }
                    
                    Button(action: {
                        
                        print("Botão 'Idioma' pressionado!")
                    }) {
                        HStack() {
                            Text("Idioma")
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        
                        print("Botão 'Sair' pressionado!")
                    }) {
                        HStack() {
                            Text("Sair")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                .listStyle(.plain)
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Versão 0.0.1")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom)
            }
            
        }
    }
}


#Preview {
    ConfiguracoesView()
}
