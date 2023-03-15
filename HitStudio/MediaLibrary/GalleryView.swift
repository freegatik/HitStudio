//
//  GalleryView.swift
//  HitStudio
//
//  Created by freegatik on 15.03.2023.
//

import SwiftUI
import PhotosUI

private enum GalleryUITestSupport {
    static func fixtureImage() -> UIImage {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer { UIGraphicsEndImageContext() }
        UIColor.systemBlue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

struct GalleryView: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            ZStack {
                Button(action: { dismiss() }) {
                    BottomPanelButton(iconName: "chevron.backward", text: "Back", isActive: false)
                    Spacer()
                }
                .accessibilityIdentifier("gallery.nav.back")
                .padding()
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .foregroundColor(Color.gray)
                    .opacity(0.07)
                    .overlay(
                        Text(LocalizedStringKey("gallery.header.photos"))
                            .font(Font.system(size: 24).weight(.bold))
                            .accessibilityIdentifier("gallery.header.photos")
                    )
                    .edgesIgnoringSafeArea(.top)
            }
                
                if selectedItem == nil && selectedImage == nil {
                    HStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(maxWidth: 110, maxHeight: 110)
                                .foregroundColor(Color.gray)
                                .opacity(0.25)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(Color.black)
                                        .font(Font.system(size: 60))
                                )
                                .aspectRatio(1/1, contentMode: .fit)
                        }
                        .padding(.leading)
                        
                        Button(action: {
                            showCamera.toggle()
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(maxWidth: 110, maxHeight: 110)
                                .foregroundColor(Color.gray)
                                .opacity(0.25)
                                .overlay(
                                    Image(systemName: "camera")
                                        .foregroundColor(Color.black)
                                        .font(Font.system(size: 60))
                                )
                                .aspectRatio(1/1, contentMode: .fit)
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                    
                    Image("arrow")
                    
                    Text(LocalizedStringKey("gallery.hint.title"))
                        .font(Font.system(size: 46).weight(.bold))
                    
                    Text(LocalizedStringKey("gallery.hint.subtitle"))
                        .multilineTextAlignment(.center)
                        .font(Font.system(size: 18).weight(.medium))
                        .foregroundColor(Color.gray)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(maxWidth: 350, maxHeight: 60)
                        .foregroundColor(Color.blue)
                        .opacity(0.3)
                        .overlay(
                            HStack {
                                Image(systemName: "hammer")
                                    .foregroundColor(.white)
                                    .font(Font.system(size: 18).weight(.medium))
                                    .padding(.trailing, 8)
                                Text(LocalizedStringKey("gallery.cta.startEditing"))
                                    .foregroundColor(.white)
                                    .font(Font.system(size: 18).weight(.medium))
                            }
                        )
                        .padding()
                    Spacer()
                }
                
                if selectedItem != nil || selectedImage != nil {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        if let selectedImageData = selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .padding()
                                .opacity(0.6)
                                .overlay(
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                            .font(Font.system(size: 60).weight(.medium))
                                            .padding(.trailing, 8)
                                    }
                                )
                        } else if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .padding()
                                .opacity(0.6)
                                .overlay(
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                            .font(Font.system(size: 60).weight(.medium))
                                            .padding(.trailing, 8)
                                    }
                                )
                        }
                    }
                    Spacer().padding(.leading)
                    Spacer()
                    NavigationLink(destination: EditingView(editImageViewModel: editImageViewModel)) {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(maxWidth: 350, maxHeight: 60)
                            .foregroundColor(Color.blue)
                            .overlay(
                                HStack {
                                    Image(systemName: "hammer")
                                        .foregroundColor(.white)
                                        .font(Font.system(size: 18).weight(.medium))
                                        .padding(.trailing, 8)
                                    Text(LocalizedStringKey("gallery.cta.startEditing"))
                                        .foregroundColor(.white)
                                        .font(Font.system(size: 18).weight(.medium))
                                }
                            )
                    }
                    .accessibilityIdentifier("gallery.nav.startEditing")
                    .padding()
                }
            }
        .onChange(of: selectedItem) { newItem in
            if let newItem = newItem {
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            if let uiImage = UIImage(data: data) {
                                editImageViewModel.originalImage = uiImage
                                editImageViewModel.nonChangedImage = uiImage
                            } else {
                                AppLogger.error("Gallery: UIImage could not be created from picker data.")
                            }
                        }
                    } catch {
                        AppLogger.error("Gallery: failed to load photo item — \(error.localizedDescription)")
                    }
                }
            }
        }
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                editImageViewModel.originalImage = newImage
                editImageViewModel.nonChangedImage = newImage
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-UITESTSeedGallery"),
               selectedImage == nil,
               selectedItem == nil {
                selectedImage = GalleryUITestSupport.fixtureImage()
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            AccessCameraView(selectedImage: $selectedImage)
        }
    }
}

struct AccessCameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: AccessCameraView
        
        init(picker: AccessCameraView) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}

struct Gallery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GalleryView(editImageViewModel: EditImageViewModel())
        }
    }
}
