import SwiftUI



struct CalendarioView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var dataDoEvento = Date()
    @State private var nomeDoEvento = ""
    @State private var localDoEvento: String = ""
    @State private var message: String = ""
    
    private let storageKey = "SavedEvents"
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Novo Evento")) {
                        DatePicker("Data e horário", selection: $dataDoEvento)
                            .datePickerStyle(.graphical)
                        
                        TextField("Título do evento", text: $nomeDoEvento)
                        Picker("Selecione um local", selection: $localDoEvento) {
                            ForEach(viewModel.local.sorted { ($0.name ?? "") < ($1.name ?? "") }) { location in
                                Text(location.name ?? "Sem nome").tag(location.name ?? "")
                            }
                        }
                        
                        Button("Enviar Evento") {
                            let novoEvento = Event(
                                _id: nil,
                                _rev: nil,
                                date: dataDoEvento,
                                title: nomeDoEvento,
                                location: localDoEvento
                            )
                            viewModel.post(novoEvento)
                        }
                        .disabled(!isFormValid)
                    }
                    
                    Section(header: Text("Eventos em \(data(dataDoEvento))")) {
                        if eventsForSelectedDate.isEmpty {
                            Text("Nenhum evento para este dia.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(eventsForSelectedDate.sorted(by: { $0.date < $1.date }), id: \.self) { event in
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                        .font(.headline)
                                    Text("Horário: \(hora(event.date))")
                                    Text("Local: \(event.location)")
                                }
                            }
                            .onDelete(perform: deleteEvent)
                        }
                    }
                }
            }
            .navigationTitle("Agenda Local")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        fetchEventosDaAPI()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Atualizar eventos")
                }
            }
            .onAppear {
                viewModel.fetch()
                fetchEventosDaAPI()
            }
        }
    }

    private var isFormValid: Bool {
        !nomeDoEvento.isEmpty && !localDoEvento.isEmpty
    }

    private var eventsForSelectedDate: [Event] {
        viewModel.evento.filter {
            Calendar.current.isDate($0.date, inSameDayAs: dataDoEvento)
        }
    }

    private func addEvent(_ newEvent: Event) {
        viewModel.evento.append(newEvent)
        saveEvents()
        nomeDoEvento = ""
        localDoEvento = ""
    }

    private func deleteEvent(at offsets: IndexSet) {
        let dayEvents = eventsForSelectedDate
        for index in offsets {
            let eventToRemove = dayEvents[index]
            if let matchIndex = viewModel.evento.firstIndex(of: eventToRemove) {
                viewModel.evento.remove(at: matchIndex)
                viewModel.remove(eventToRemove) // remove da API
            }
        }
    }

    private func saveEvents() {
        if let data = try? JSONEncoder().encode(viewModel.evento) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func data(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func hora(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func fetchEventosDaAPI() {
        guard let url = URL(string: "http://192.168.128.15:1880/getEventos") else {
            self.message = "URL inválida"
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Erro na requisição: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.message = "Nenhum dado retornado"
                    return
                }

                do {
                    let eventosRecebidos = try decoder.decode([Event].self, from: data)
                    viewModel.evento = eventosRecebidos
                    self.message = "✅ Eventos carregados com sucesso!"
                } catch {
                    self.message = "Erro ao decodificar JSON: \(error.localizedDescription)"
                    print(String(data: data, encoding: .utf8) ?? "Dados brutos indisponíveis")
                }
            }
        }.resume()
    }
}

#Preview {
    CalendarioView()
}
