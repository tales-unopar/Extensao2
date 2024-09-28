//
//  Repository.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import Foundation

class Repository: ObservableObject {
    enum Constants {
        static let fileName = "loteamentos.json"
    }
    
    @Published
    var loteamentos: [Loteamento] = [] {
        didSet {
            Task {
                saveToDisk(self.loteamentos)
            }
        }
    }
    
    init() {
        self.loteamentos = getLoteamentos()
    }
    
    func getLoteamentos() -> [Loteamento] {
        let url = getDocumentsDirectory().appendingPathComponent(Constants.fileName)
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url)
            let loteamentos = try decoder.decode([Loteamento].self, from: data)
            
            self.loteamentos = loteamentos
            
            return loteamentos
        } catch {
            print("Failed to load structs: \(error.localizedDescription)")
            return []
        }
    }
    
    func saveLoteamento(_ loteamento: Loteamento) {
        loteamentos.append(loteamento)
    }
    
    func updateLoteamento(_ loteamento: Loteamento) {
        guard let index = loteamentos.firstIndex(where: { $0 == loteamento }) else { return }
        
        loteamentos[index] = loteamento
    }
    
    func removeLoteamento(_ loteamento: Loteamento) {
        loteamentos.removeAll(where: { $0 == loteamento })
    }
    
    func updatePayment(_ payment: Payment, loteamento: Loteamento) {
        guard let paymentIndex = loteamento.payments.firstIndex(where: { $0.id == payment.id }) else { return }
        
        loteamento.payments[paymentIndex] = payment
        
        updateLoteamento(loteamento)
    }
    
    func saveToDisk(_ loteamentos: [Loteamento]) {
        let url = getDocumentsDirectory().appendingPathComponent(Constants.fileName)
                
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(loteamentos)
            try data.write(to: url)
            print("Saved structs to \(url)")
        } catch {
            print("Failed to save structs: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
