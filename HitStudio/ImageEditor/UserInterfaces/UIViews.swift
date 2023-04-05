//
//  UIViews.swift
//  HitStudio
//
//  Created by freegatik on 05.04.2023.
//

import SwiftUI

struct TopPanelBackButton: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 22))
            .foregroundColor(.white)
            .font(Font.system(size: 16).weight(.medium))
            .frame(width: 40, height: 40)
            .background(Color.black)
            .cornerRadius(10)
    }
}

struct TopPanelButton: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 22))
            .foregroundColor(.gray)
            .font(Font.system(size: 16).weight(.medium))
            .frame(width: 40, height: 40)
            .background(Color.black)
            .cornerRadius(10)
    }
}

struct BottomPanelButton: View {
    let iconName: String
    let text: String
    let isActive: Bool
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 25))
                .foregroundColor(isActive ? .blue : .gray)
                .font(Font.system(size: 16).weight(.medium))
                .frame(width: 30, height: 30)
            Text(text)
                .foregroundColor(isActive ? .blue : .gray)
                .font(Font.system(size: 17).weight(.light))
        }
    }
}

struct RotateUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    @State private var rotateSliderValue: Int = 90
    var rotateAction: (() -> Void)?
    
    var body: some View {
        
        Slider(value: Binding<Double>(
            get: { Double(rotateSliderValue) },
            set: { newValue in rotateSliderValue = Int(newValue) }
        ), in: 0...360, step: 1)
        .accentColor(.gray)
        .padding(.horizontal)
        .onChange(of: rotateSliderValue) { newValue in
            editImageViewModel.rotateSliderValue = newValue
        }
        .onAppear {
            editImageViewModel.rotateSliderValue = rotateSliderValue
        }
        
        Text("Angle: \(rotateSliderValue)°")
            .foregroundColor(.gray)
            .font(Font.system(size: 18).weight(.light))
            .padding()
        if !editImageViewModel.isProcessing {
            Button(action: {
                rotateAction?()
            }) {
                Text("Rotate")
                    .foregroundColor(.white)
                    .font(Font.system(size: 18).weight(.medium))
                    .frame(width: 160, height: 55)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        } else {
            Button(action: {
            }) {
                Text("Rotate")
                    .foregroundColor(.white)
                    .font(Font.system(size: 18).weight(.medium))
                    .frame(width: 160, height: 55)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        
        Spacer()
    }
}

struct ResizeUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    @State private var resizeSliderValue: Double = 1.0
    var resizeAction: (() -> Void)?
    
    var body: some View {
        Slider(value: $resizeSliderValue, in: 0.5...2, step: 0.1)
            .accentColor(.gray)
            .padding(.horizontal)
            .onChange(of: resizeSliderValue) { newValue in
                editImageViewModel.resizeSliderValue = newValue
            }
        
        Text("Scaling: \(resizeSliderValue, specifier: "%.2f")x")
            .foregroundColor(.gray)
            .font(Font.system(size: 18).weight(.light))
            .padding()
        
        if !editImageViewModel.isProcessing {
            Button(action: {
                resizeAction?()
            }) {
                Text("Resize")
                    .foregroundColor(.white)
                    .font(Font.system(size: 18).weight(.medium))
                    .frame(width: 160, height: 55)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        } else {
            Button(action: {
            }) {
                Text("Resize")
                    .foregroundColor(.white)
                    .font(Font.system(size: 18).weight(.medium))
                    .frame(width: 160, height: 55)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        
        Spacer()
    }
}

struct FiltersUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    @State private var mosaicSliderValue: Int = 3
    var negativeAction: (() -> Void)?
    var mosaicAction: (() -> Void)?
    var medianAction: (() -> Void)?
    var gaussianBlurAction: (() -> Void)?
    
    var body: some View {
        HStack {
            if !editImageViewModel.isProcessing {
                Button(action: {
                    negativeAction?()
                }) {
                    BottomPanelButton(iconName: "minus.diamond", text: "Negative", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    mosaicAction?()
                }) {
                    BottomPanelButton(iconName: "mosaic", text: "Mosaic", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    medianAction?()
                }) {
                    BottomPanelButton(iconName: "divide.square", text: "Median", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    gaussianBlurAction?()
                }) {
                    BottomPanelButton(iconName: "laser.burst", text: "Gaussian blur", isActive: false)
                }
            } else {
                Button(action: {
                    
                }) {
                    BottomPanelButton(iconName: "minus.diamond", text: "Negative", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    BottomPanelButton(iconName: "mosaic", text: "Mosaic", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    BottomPanelButton(iconName: "divide.square", text: "Median", isActive: false)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    BottomPanelButton(iconName: "laser.burst", text: "Gaussian blur", isActive: false)
                }
            }
            
        }
        .padding(.horizontal, 30)
        
        Spacer()
        
        Slider(value: Binding<Double>(
            get: { Double(mosaicSliderValue) },
            set: { newValue in mosaicSliderValue = Int(newValue) }
        ), in: 3...15, step: 1)
        .accentColor(.gray)
        .padding(.horizontal)
        .onChange(of: mosaicSliderValue) { newValue in
            editImageViewModel.mosaicSliderValue = newValue
        }
        .onAppear {
            editImageViewModel.mosaicSliderValue = mosaicSliderValue
        }
        
        Text("Mosaic block size: \(mosaicSliderValue) px")
            .foregroundColor(.gray)
            .font(Font.system(size: 18).weight(.light))
            .padding()
    }
}

struct RetouchUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    var retouchAction: (() -> Void)?
    var confirmAction: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack {
                Text("Brush Size: \(Int(editImageViewModel.brushSize))")
                    .foregroundColor(.white)
                    .font(Font.system(size: 16).weight(.light))
                    .padding(.vertical, 5)
                
                Slider(value: $editImageViewModel.brushSize, in: 5...100, step: 1)
                    .accentColor(.blue)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            
            VStack {
                Text("Retouch Strength: \(String(format: "%.2f", editImageViewModel.retouchStrength))")
                    .foregroundColor(.white)
                    .font(Font.system(size: 16).weight(.light))
                    .padding(.vertical, 5)
                
                Slider(value: $editImageViewModel.retouchStrength, in: 0...1)
                    .accentColor(.blue)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            
            VStack {
                Button(action: {
                    confirmAction?()
                }) {
                    Text("Confirm")
                        .foregroundColor(.white)
                        .font(Font.system(size: 18).weight(.medium))
                        .frame(width: 160, height: 55)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom, 20)
                }
            }
        }
        
    }
}

struct MaskingUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    @State private var thresholdSliderValue: Int = 20
    @State private var amountSliderValue: Int = 50
    @State private var radiusSliderValue: Int = 1
    
    var maskingAction: (() -> Void)?
    
    var body: some View {
        VStack {
            
            Slider(value: Binding<Double>(
                get: { Double(thresholdSliderValue) },
                set: { newValue in thresholdSliderValue = Int(newValue) }
            ), in: 0...100, step: 1)
            .accentColor(.gray)
            .padding(.horizontal)
            .onChange(of: thresholdSliderValue) { newValue in
                editImageViewModel.thresholdSliderValue = newValue
            }
            .onAppear {
                editImageViewModel.thresholdSliderValue = thresholdSliderValue
            }
            
            Text("Threshold: \(thresholdSliderValue)")
                .foregroundColor(.gray)
                .font(Font.system(size: 18).weight(.light))
                .padding()
            
            Slider(value: Binding<Double>(
                get: { Double(amountSliderValue) },
                set: { newValue in amountSliderValue = Int(newValue) }
            ), in: 1...100, step: 1)
            .accentColor(.gray)
            .padding(.horizontal)
            .onChange(of: amountSliderValue) { newValue in
                editImageViewModel.amountSliderValue = newValue
            }
            .onAppear {
                editImageViewModel.amountSliderValue = amountSliderValue
            }
            
            Text("Amount: \(amountSliderValue)")
                .foregroundColor(.gray)
                .font(Font.system(size: 18).weight(.light))
                .padding()
            
            Slider(value: Binding<Double>(
                get: { Double(radiusSliderValue) },
                set: { newValue in radiusSliderValue = Int(newValue) }
            ), in: 1...5, step: 1)
            .accentColor(.gray)
            .padding(.horizontal)
            .onChange(of: radiusSliderValue) { newValue in
                editImageViewModel.radiusSliderValue = newValue
            }
            .onAppear {
                editImageViewModel.radiusSliderValue = radiusSliderValue
            }
            
            Text("Radius: \(radiusSliderValue)")
                .foregroundColor(.gray)
                .font(Font.system(size: 18).weight(.light))
                .padding()
        }
        if !editImageViewModel.isProcessing {
            Button(action: {
                maskingAction?()
            }) {
                Text("Start")
                    .foregroundColor(.white)
                    .font(Font.system(size: 16).weight(.medium))
                    .frame(maxWidth: 200, maxHeight: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(30)
        } else {
            Button(action: {
                maskingAction?()
            }) {
                Text("Start")
                    .foregroundColor(.white)
                    .font(Font.system(size: 16).weight(.medium))
                    .frame(maxWidth: 200, maxHeight: 40)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .padding(30)
        }
        
    }
}

struct TransformationUI: View {
    @ObservedObject var editImageViewModel: EditImageViewModel
    var transformAction: (() -> Void)?
    var clearAction: (() -> Void)?
    
    var body: some View {
        HStack {
            if !editImageViewModel.isProcessing {
                Button(action: {
                    transformAction?()
                }) {
                    Text("Transform")
                        .foregroundColor(.white)
                        .font(Font.system(size: 18).weight(.medium))
                        .frame(width: 160, height: 55)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom, 30)
                }
                
                Button(action: {
                    clearAction?()
                }) {
                    Text("Delete points")
                        .foregroundColor(.white)
                        .font(Font.system(size: 18).weight(.medium))
                        .frame(width: 160, height: 55)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom, 30)
                }
            } else {
                Button(action: {
                    transformAction?()
                }) {
                    Text("Transform")
                        .foregroundColor(.white)
                        .font(Font.system(size: 18).weight(.medium))
                        .frame(width: 160, height: 55)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom, 30)
                }
                
                Button(action: {
                    clearAction?()
                }) {
                    Text("Delete points")
                        .foregroundColor(.white)
                        .font(Font.system(size: 18).weight(.medium))
                        .frame(width: 160, height: 55)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom, 30)
                }
            }
        }
    }
}
