//
//  SlideshowView.swift
//  test
//
//  Created by Enrico on 02/08/24.
//

import SwiftUI

class CardSelection: ObservableObject {
    @Published var selectedCardID: Int? = nil
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    
    func selectCardCoords(latitude lat: Double, longitude lng: Double) {
        latitude = lat
        longitude = lng
    }
    func selectCardID(withId id: Int) {
        selectedCardID = id
    }
}


struct SlideshowView: View {
    @ObservedObject var selection: CardSelection
    var cards: [CardItem]
    var selectionHandler: ((_ title: String ,_ lat: Double, _ lng: Double)->Void)?
    var detailsNavigationHandler: (() -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(cards) { card in
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: card.coverMobileThumbnail)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 250, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } placeholder: {
                            Color.gray
                                .frame(width: 250, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        
                        VStack {
                            Text(card.name)
                                .font(.custom("Poppins-Bold", size: 14))
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if (selection.latitude == card.latitude && selection.longitude == card.longitude) || selection.selectedCardID == card.id {
                                Text(card.address)
                                    .font(.custom("Poppins-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .opacity(0.85)
                                    .padding(.horizontal, 20)
                                    .padding(.top, -20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                                Button(action: {
                                    detailsNavigationHandler?()
                                }) {
                                    Text("DETAILS")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 28)
                                                .stroke(Color.white, lineWidth: 1)
                                                .frame(width: 175)
                                        )
                                }
                                .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity((selection.latitude == card.latitude && selection.longitude == card.longitude) || selection.selectedCardID == card.id ? 0.80 : 0.65))
                        .clipShape(BottomRoundedRectangle())
                    }
                    .frame(width: 250)
                    .background(Color.clear)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .onTapGesture {
                        selection.selectCardID(withId: card.id)
                        selection.selectCardCoords(latitude: card.latitude, longitude: card.longitude)
                        selectionHandler?(card.name ,card.latitude, card.longitude)
                        }
                }
            }
            .padding()
        }
        .background(.clear)
    }
}

struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 15
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius)
        let bottomCenter = CGPoint(x: rect.midX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY - cornerRadius)
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: bottomCenter)
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        
        return path
    }
}
