import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var selectedLocation: Localizacao? = nil
    @State private var isSheetPresented = false
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -15.76, longitude: -47.87),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $mapPosition) {
                    ForEach(viewModel.local) { local in
                        if let lat = local.latitude, let lon = local.longitude {
                            Annotation(local.name ?? "Sem nome", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                Button {
                                    selectedLocation = local
                                    isSheetPresented = true
                                } label: {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.blue)
                                        .font(.title)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                VStack {
                    if viewModel.isLoading {
                        ProgressView("Carregando locais...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    if !viewModel.local.isEmpty {
                        HStack{
                            Picker("Selecione um local", selection: $selectedLocation) {
                                ForEach(viewModel.local.sorted { ($0.name ?? "") < ($1.name ?? "") }) { location in
                                    Text(location.name ?? "Sem nome").tag(Optional(location))
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 2))
                            .padding(.horizontal)
                            .onChange(of: selectedLocation) { newValue in
                                if let location = newValue,
                                   let lat = location.latitude,
                                   let lon = location.longitude {
                                    mapPosition = MapCameraPosition.region(
                                        MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                        )
                                    )
                                }
                            }
                            Button(action: resetMap) {
                                Image(systemName: "paperplane.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mapa")
            .onAppear {
                viewModel.fetch()
            }
            .sheet(isPresented: $isSheetPresented) {
                if let selected = selectedLocation {
                    EventListView(localName: selected.name ?? "")
                }
            }
        }
    }

    private func resetMap() {
        mapPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -15.76, longitude: -47.87),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
        selectedLocation = nil
    }
}


#Preview {
    ContentView()
}
