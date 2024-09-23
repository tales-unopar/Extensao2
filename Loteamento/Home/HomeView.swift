//
//  ContentView.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject
    var repository = Repository()
    
    @State private var isShowingCreate = false
    
    @State var newLoteamentoName: String = ""
    
    @State var newLoteamentoDescription: String = ""
    
    var loteamentosList: some View {
        VStack {
            if repository.loteamentos.isEmpty {
                Text("Nenhum loteamento encontrado.")
            } else {
                List {
                    ForEach(repository.loteamentos, id: \.id) { loteamento in
                        NavigationLink {
                            DetailsView(loteamento: loteamento, repository: repository)
                        } label: {
                            Text(loteamento.name)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(GroupedListStyle())
                .background(Color.clear)
            }
        }
        .background(Color.clear)
    }
    
    var body: some View {
        NavigationStack {
            loteamentosList
                .navigationTitle("Loteamentos")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowingCreate.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .alert("Crie um novo loteamento", isPresented: $isShowingCreate) {
            TextField("Nome", text: $newLoteamentoName)
            TextField("Descrição", text: $newLoteamentoDescription)
            Button("OK", action: createLoteamento)
        } message: {
            Text("Um novo loteamento será criado e você poderá adicionar os detalhes mais tarde.")
        }
    }
    
    func createLoteamento() {
        guard !newLoteamentoName.isEmpty else { return }
        
        let loteamento = Loteamento(id: UUID().uuidString, name: newLoteamentoName, description: newLoteamentoDescription, payments: [])
        
        repository.saveLoteamento(loteamento)
        
        newLoteamentoName = ""
        newLoteamentoDescription = ""
    }
    
    func delete(at offsets: IndexSet) {
        repository.loteamentos.remove(atOffsets: offsets)
    }
}


#Preview {
    HomeView()
}
