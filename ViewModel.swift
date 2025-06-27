import Foundation
import SwiftUI

struct Event: Decodable, Encodable, Hashable {
    let _id : String?
    let _rev: String?
    let date: Date
    let title: String
    let location: String
}

struct Localizacao: Identifiable, Decodable, Hashable {
    let id = UUID()
    let name: String?
    let latitude: Double?
    let longitude: Double?
}

class ViewModel: ObservableObject {
    @Published var local: [Localizacao] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var evento: [Event] = []

    func fetch() {
        guard let url = URL(string: "http://192.168.128.15:1880/GetCadastro") else {
            errorMessage = "URL inválida."
            return
        }

        isLoading = true
        errorMessage = nil

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Erro na requisição: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Nenhum dado recebido do servidor."
                }
                return
            }

            do {
                let parsed = try JSONDecoder().decode([Localizacao].self, from: data)
                DispatchQueue.main.async {
                    self?.local = parsed
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Erro ao decodificar os dados: \(error.localizedDescription)"
                }
            }
        }

        task.resume()
    }
    
    func post(_ obj: Event){
        
        guard let url = URL(string: "http://192.168.128.15:1880/postEventos") else { return } //Aqui deve ser colocado o IP (local ou da rede) e, depois da barra, o verbo do POST do Node-RED
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(obj)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            print("Error encoding to JSON: \(error.localizedDescription)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error to send resource: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error to send resource: invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Resource POST successfully")
            } else {
                print("Error POST resource: status code \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
    func remove(_ c: Event){

        guard let url = URL(string: "http://192.168.128.15:1880/deleteEventos") else { return } //Aqui deve ser colocado o IP (local ou da rede) e, depois da barra, o verbo escolhido no fluxo do DELETE no Node-RED
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let data = try JSONEncoder().encode(c)
            
            print(c)
            
            request.httpBody = data
            
        } catch {
            print("Error encoding to JSON: \(error.localizedDescription)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting resource: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error deleting resource: invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Resource deleted successfully")
            } else {
                print("Error deleting resource: status code \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
        
        if let index = self.evento.firstIndex(of: c) {
            DispatchQueue.main.async {
                self.evento.remove(at: index)
            }
        }
    }
}
