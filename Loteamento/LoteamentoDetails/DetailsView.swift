//
//  DetailsView.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import SwiftUI
import Photos
import PhotosUI

struct DetailsView: View {
    @ObservedObject var loteamento: Loteamento
    @State private var isShowingNew = false
    @State private var isShowingEdit = false
    @State private var isShowingImagePicker = false
    @State private var isShowingFullImage = false
    @State private var selectedPayment: Payment?
    @State private var selectedImage: UIImage?
    
    @ObservedObject var repository: Repository
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var description: String = ""
    @State var address: String = ""
    
    @State var paymentAmount: String = ""
    @State var paymentDescription: String = ""
    @State var paymentPaidBy: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var loteamentoDescription: some View {
        VStack {
            if !loteamento.getPresentationText().isEmpty {
                Text(loteamento.getPresentationText())
                    .onTapGesture {
                        isShowingEdit.toggle()
                    }
                    .alert("Editar campos", isPresented: $isShowingEdit) {
                        TextField("Nome", text: $name)
                        TextField("Descrição", text: $description)
                        TextField("Endereço", text: $address)
                        Button("OK") {
                            updateLoteamento()
                        }
                    }
            }
        }
    }
    
    var paymentList: some View {
        VStack {
            if loteamento.payments.isEmpty {
                Text("Nenhum pagamento encontrado.")
            } else {
                List {
                    ForEach(loteamento.payments) { payment in
                        CardView {
                            HStack {
                                Text(payment.description)
                                Spacer()
                                Text(String(format: "%.2f", payment.amount))
                                
                                if let imageData = payment.imageData, let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .onTapGesture {
                                            selectedImage = image
                                            isShowingFullImage = true
                                        }
                                } else {
                                        Button(action: {
                                            requestPhotoLibraryAccess { granted in
                                                if granted {
                                                    selectedPayment = payment
                                                    isShowingImagePicker = true
                                                } else {
                                                    print("Acesso negado")
                                                }
                                            }
                                        }) {
                                            Image(systemName: "photo")
                                        }
                                }
                            }
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
        NavigationView {
            VStack {
                loteamentoDescription
                Spacer()
                paymentList
                Spacer()
            }
            .background(Color.clear)
            .navigationTitle(loteamento.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isShowingNew.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            if let payment = selectedPayment {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Selecione a foto")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
            }
        }
        .sheet(isPresented: $isShowingFullImage) {
            if let selectedImage = selectedImage {
                FullImageView(image: selectedImage)
            }
        }
        .alert("Crie um novo pagamento", isPresented: $isShowingNew) {
            TextField("Quantia", text: $paymentAmount)
            TextField("Descrição", text: $paymentDescription)
            TextField("Pago por", text: $paymentPaidBy)
            Button("OK", action: newPayment)
        }
        .onAppear { updateFields() }
    }
    
    func updateFields() {
        description = loteamento.description ?? ""
        address = loteamento.address ?? ""
        name = loteamento.name
    }
    
    func updateLoteamento() {
        if !description.isEmpty { loteamento.description = description }
        if !address.isEmpty { loteamento.address = address }
        if !name.isEmpty { loteamento.name = name }
        repository.updateLoteamento(loteamento)
    }
    
    func newPayment() {
        let payment = Payment(id: UUID().uuidString, amount: Double(paymentAmount) ?? 0.0, description: paymentDescription, paidBy: paymentPaidBy)
        
        loteamento.payments.append(payment)
        
        repository.updateLoteamento(loteamento)
    }
    
    func delete(at offsets: IndexSet) {
        loteamento.payments.remove(atOffsets: offsets)
        repository.updateLoteamento(loteamento)
    }
    
    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .authorized)
            }
        @unknown default:
            completion(false)
        }
    }
}


#Preview {
    DetailsView(loteamento: Loteamento(id: "1239393029", name: "Tales Lotes", description: "Um loteamento cheio de coisas", address: "Rua 123 Maior", owner: "Test", payments: []), repository: Repository())
}
