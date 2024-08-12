//
//  SwiftUIView.swift
//  test
//
//  Created by Enrico on 02/08/24.
//

import SwiftUI

struct SearchResult: Identifiable {
    var id: Int = 0
    var title: String
    var searched: Bool = false
}

class SearchValues: ObservableObject {
    @Published var filtered: [SearchResult]? = nil
    func setSearched(withId id: Int) {
        guard var filtered = self.filtered else {
            print("Invalid initial search list")
            return
        }
        if let index = filtered.firstIndex(where: { $0.id == id }) {
            filtered[index].searched = true
            self.filtered = filtered
        }
    }
}

struct SearchResultsView: View {
    @StateObject var searchValues: SearchValues
    var selectionHandler: ((_ id: Int)->Void)?
    
    var body: some View {
        if let filteredResults = searchValues.filtered {
            VStack(alignment: .leading) {
                Text("SEARCH RESULTS")
                    .font(.custom("Poppins-Bold", size: 13))
                    .foregroundColor(Color(uiColor: UIColor(hex: "#313131") ?? .black))
                    .padding([.top, .leading, .bottom], 20)
                List(filteredResults) { result in
                    HStack {
                        Image(uiImage: UIImage(named: result.searched ? "xml-searchresults" : "xml-pinresults")!)
                            .foregroundColor(result.searched ? .yellow : .black)
                            .padding(.horizontal, 20)
                        Text(result.title)
                            .font(.custom("Poppins-Bold", size: 12))
                    }
                    .padding()
                    .onTapGesture {
                        selectionHandler?(result.id)
                    }
                }
                .listStyle(InsetListStyle())
            }
        }
    }
}

