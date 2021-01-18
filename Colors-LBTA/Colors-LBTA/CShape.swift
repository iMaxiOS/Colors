//
//  CShape.swift
//  Colors-LBTA
//
//  Created by Maxim Granchenko on 18.01.2021.
//

import SwiftUI

struct CShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topRight, .bottomLeft],
                                cornerRadii: CGSize(width: 55, height: 55))
        
        return Path(path.cgPath)
    }
}

