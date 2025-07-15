//
//  InnerComponents.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                content()
                    .padding(.bottom, spacing)
                    .alignmentGuide(.leading) { d in
                        if abs(x - d.width) > maxWidth {
                            x = 0
                            y -= d.height + spacing
                        }
                        defer { x -= d.width + spacing }
                        return x
                    }
                    .alignmentGuide(.top) { _ in y }
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

enum Period: String, CaseIterable, Identifiable {
    case h1 = "1h" , h3 = "3h", h12 = "12h", h24 = "24h", d7 = "7d", d30 = "30d", y1 = "1y"
    var id: Self { self }
    var label: String { rawValue.uppercased() }
}

struct SegmentedPicker: UIViewRepresentable {
    @Binding var selected: Period
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: Period.allCases.map(\.label))
        control.selectedSegmentIndex = Period.allCases.firstIndex(of: selected) ?? 0
        control.addTarget(context.coordinator, action: #selector(Coordinator.changed), for: .valueChanged)
        
        control.selectedSegmentTintColor = UIColor.systemGreen
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        
        control.layer.cornerRadius = 0
        control.clipsToBounds = true
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = Period.allCases.firstIndex(of: selected) ?? 0
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SegmentedPicker
        
        init(_ parent: SegmentedPicker) {
            self.parent = parent
        }
        
        @objc func changed(_ sender: UISegmentedControl) {
            let index = sender.selectedSegmentIndex
            parent.selected = Period.allCases[index]
        }
    }
}

struct TagTile: View {
   let tag: Tag
   var rank: Int = 1
   
   var tagName: String {
       tag.shortname ?? tag.name ?? "Unknown"
   }
   
   var url: String {
       tag.iconURL ?? ""
   }
   
   var body: some View {
       VStack(spacing: 0) {
           
           CircularImageView(url: url, size: CGSize(width: 40, height: 40))
               .clipShape(RoundedRectangle(cornerRadius: 14))
               .padding(2)

           Text(tagName)
               .font(.system(size: 10))
               .multilineTextAlignment(.center)
               .padding(.vertical, 10)
               .frame(maxWidth: .infinity)
           
           Divider()
           
           HStack(spacing: 4) {
               Image(systemName: "medal")
                   .font(.system(size: 14))
                   .foregroundColor(.yellow)
               Text("#\(rank)")
                   .font(.footnote.weight(.semibold))
           }
           .frame(maxWidth: .infinity)
           .padding(.vertical, 10)
       }
       .frame(width: 100, height: 140)
       .background(
           RoundedRectangle(cornerRadius: 6)
               .stroke(Color(.systemGray4), lineWidth: 1)
       )
   }
}

struct TagStrip: View {
   let tags: [Tag]
   
   var body: some View {
       ScrollView(.horizontal, showsIndicators: false) {
           LazyHStack(spacing: 16) {
               ForEach(tags, id: \.slug) { tag in
                   TagTile(tag: tag)
               }
           }
           .padding(.horizontal, 10)
       }
   }
}
