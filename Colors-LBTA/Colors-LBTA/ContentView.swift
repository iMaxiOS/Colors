//
//  ContentView.swift
//  Colors-LBTA
//
//  Created by Maxim Granchenko on 18.01.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State var show = false
    @State var searchText = ""
    @State var filtered: [Gradient] = []
    @State var gradients: [Gradient] = []
    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                if show {
                    HStack {
                        TextField("Search Color", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: searchText) { value in
                                if searchText != "" {
                                    searchColor()
                                } else {
                                    searchText = ""
                                    filtered = gradients
                                }
                            }
                        
                        Button(action: {
                            withAnimation(.easeOut) {
                                searchText = ""
                                filtered = gradients
                                show.toggle()
                            }
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        })
                    }
                } else {
                    Text("Gradient")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut) {
                            show.toggle()
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    })
                    
                    Button(action: {
                        withAnimation(.easeOut) {
                            if columns.count == 1 {
                                columns.append(GridItem(.flexible(), spacing: 20))
                            } else {
                                columns.removeLast()
                            }
                        }
                    }, label: {
                        Image(systemName: columns.count == 1 ? "square.grid.2x2.fill" : "rectangle.grid.1x2.fill")
                            .font(.system(size: columns.count == 1 ? 20 : 17, weight: .bold))
                            .foregroundColor(.white)
                    })
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            .padding(.horizontal)
            .zIndex(1)
            
            if gradients.isEmpty {
                ProgressView()
                    .padding(.top, 55)
                
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20, content: {
                        ForEach(filtered, id: \.name) { color in
                            
                            VStack {
                                ZStack {
                                    LinearGradient(gradient: .init(colors: hexToRGB(colors: color.colors)),
                                                   startPoint: .bottom,
                                                   endPoint: .top)
                                        .frame(height: 180)
                                        .clipShape(CShape())
                                        .cornerRadius(10)
                                    
                                    Text(color.name)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                
                                if columns.count == 1 {
                                    HStack(spacing: 15) {
                                        ForEach(color.colors, id: \.self) { color in
                                            Text(color)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
                .zIndex(0)
            }
        }
        .onAppear(perform: {
            getColors()
        })
    }
    
    
    func getColors() {
        let url = "https://raw.githubusercontent.com/ghosh/uiGradients/master/gradients.json"
        let seesion = URLSession(configuration: .default)
        
        seesion.dataTask(with: URL(string: url)!) { (data, _, _) in
            guard let jsonData = data else { return }
            
            do {
                let gradients = try JSONDecoder().decode([Gradient].self, from: jsonData)
                self.gradients = gradients
                self.filtered = gradients
            } catch {
                print(error)
            }
        }
        .resume()
    }
    
    func hexToRGB(colors: [String]) -> [Color] {
        var colors1 : [Color] = []
        
        for color in colors {
            var trimmed = color.trimmingCharacters(in: .whitespaces).uppercased()
            trimmed.remove(at: trimmed.startIndex)
            
            var hexValue : UInt64 = 0
            Scanner(string: trimmed).scanHexInt64(&hexValue)
            
            let r = CGFloat((hexValue & 0x00FF0000) >> 16) / 255
            let g = CGFloat((hexValue & 0x0000FF00) >> 8) / 255
            let b = CGFloat((hexValue & 0x000000FF)) / 255
            
            colors1.append(Color(UIColor(red: r, green: g, blue: b, alpha: 1.0)))
        }
        
        return colors1
    }
    
    func searchColor() {
        let query = searchText.lowercased()
        
        DispatchQueue.global(qos: .background).async {
            let filter = gradients.filter { (gradient) -> Bool in
                if gradient.name.lowercased().contains(query) {
                    return true
                } else {
                    return false
                }
            }
            
            DispatchQueue.main.async {
                withAnimation(.easeOut) {
                    self.filtered = filter
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
