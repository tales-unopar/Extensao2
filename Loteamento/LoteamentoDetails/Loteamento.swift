//
//  Loteamento.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import Foundation
import SwiftUI

class Loteamento: Codable, Identifiable, Equatable, ObservableObject {
    let id: String
    var name: String
    var description: String?
    var address: String?
    var owner: String?
    var payments: [Payment]
    
    static func == (lhs: Loteamento, rhs: Loteamento) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String, name: String, description: String? = nil, address: String? = nil, owner: String? = nil, payments: [Payment]) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.owner = owner
        self.payments = payments
    }
    
    func getPresentationText() -> String {
        var text = ""
        
        if let description {
            text += "Descrição: \(description)"
        }
        
        if let address {
            text += "\nEndereço: \(address)"
        }
        
        return text
    }
}

struct Payment: Codable, Identifiable, Equatable {
    let id: String
    var amount: Double
    var description: String
    var paidBy: String
    var imageData: Data?
}
