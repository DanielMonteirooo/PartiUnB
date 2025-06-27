import SwiftUI

struct EventListView: View {
    @StateObject private var viewModel = ViewModel()
    let localName: String

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.evento.filter { $0.location == localName }, id: \.self) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title)
                            .font(.headline)
                        Text("Data: \(formattedDate(event.date))")
                        Text("Hora: \(formattedTime(event.date))")
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Eventos em \(localName)")
            .onAppear {
                fetchEventos()
            }
        }
    }

    func fetchEventos() {
        guard let url = URL(string: "http://192.168.128.15:1880/getEventos") else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let eventos = try? decoder.decode([Event].self, from: data) {
                    DispatchQueue.main.async {
                        viewModel.evento = eventos
                    }
                }
            }
        }.resume()
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
