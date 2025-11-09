import SwiftUI
import MapKit
import Combine

struct LocationPickerView: View {
    @StateObject private var locationHelper = LocationSearchHelper()
    @Environment(\.dismiss) var dismiss
    
    let onLocationSelected: (Location) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField(NSLocalizedString("search_location", comment: ""), text: $locationHelper.searchQuery)
                        .textFieldStyle(.plain)
                    
                    if !locationHelper.searchQuery.isEmpty {
                        Button(action: {
                            locationHelper.clearSelection()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if !locationHelper.searchResults.isEmpty {
                    // Search results list
                    List {
                        ForEach(locationHelper.searchResults, id: \.self) { result in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title)
                                    .font(.body)
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptics.light()
                                locationHelper.selectLocation(from: result)
                            }
                        }
                    }
                    .listStyle(.plain)
                } else if let location = locationHelper.selectedLocation {
                    // Map preview
                    VStack(spacing: 12) {
                        MapPreview(location: location)
                            .frame(height: 250)
                            .cornerRadius(12)
                            .padding()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(NSLocalizedString("search_location_prompt", comment: ""))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle(NSLocalizedString("add_location", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        Haptics.light()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        if let location = locationHelper.selectedLocation {
                            Haptics.success()
                            onLocationSelected(location)
                            dismiss()
                        }
                    }
                    .disabled(locationHelper.selectedLocation == nil)
                }
            }
        }
    }
}

struct MapPreview: View {
    let location: Location
    
    @State private var region: MKCoordinateRegion
    
    init(location: Location) {
        self.location = location
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Map(position: .constant(.region(region))) {
                Marker(location.name, coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                ))
            }
        } else {
            Map(coordinateRegion: .constant(region),
                annotationItems: [location]) { loc in
                MapMarker(coordinate: CLLocationCoordinate2D(
                    latitude: loc.latitude,
                    longitude: loc.longitude
                ), tint: .red)
            }
        }
    }
}

// MARK: - Location Search Helper

class LocationSearchHelper: NSObject, ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedLocation: Location?
    
    private let completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
        
        // Observe search query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.searchResults = []
                } else {
                    self?.completer.queryFragment = query
                }
            }
            .store(in: &cancellables)
    }
    
    func selectLocation(from completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let response = response,
                  let mapItem = response.mapItems.first else {
                return
            }
            
            let coordinate = mapItem.placemark.coordinate
            let name = mapItem.name ?? completion.title
            let address = [
                mapItem.placemark.thoroughfare,
                mapItem.placemark.subThoroughfare,
                mapItem.placemark.locality,
                mapItem.placemark.postalCode,
                mapItem.placemark.country
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
            
            self?.selectedLocation = Location(
                name: name,
                address: address.isEmpty ? completion.subtitle : address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            
            self?.searchQuery = name
            self?.searchResults = []
        }
    }
    
    func clearSelection() {
        selectedLocation = nil
        searchQuery = ""
        searchResults = []
    }
}

extension LocationSearchHelper: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search error: \(error.localizedDescription)")
        searchResults = []
    }
}
