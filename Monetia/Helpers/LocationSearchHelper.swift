import Foundation
import MapKit
import Combine

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

struct Location: Codable, Equatable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}
