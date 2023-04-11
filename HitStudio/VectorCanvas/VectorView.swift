//
//  VectorView.swift
//  HitStudio
//
//  Created by freegatik on 08.04.2023.
//

import SwiftUI
import CoreGraphics

struct ConvertButton: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .foregroundColor(Color.blue)
                .overlay(
                    HStack {
                        Text("Convert to spline")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18).weight(.medium))
                        Image(systemName: "pencil.and.outline")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18).weight(.medium))
                            .padding(.trailing, 8)
                    }
                )
        }
    }
}

struct DrawAnotherButton: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .foregroundColor(Color.gray)
                .overlay(
                    HStack {
                        Text("Draw another spline")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18).weight(.medium))
                        Image(systemName: "pencil.and.outline")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18).weight(.medium))
                            .padding(.trailing, 8)
                    }
                )
        }
    }
}

struct VectorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var points: [CGPoint] = []
    @State private var splinePoints: [CGPoint] = []
    @State private var canAddPoints = true
    @State private var undoStack: [CGPoint] = []
    @State private var redoStack: [CGPoint] = []
    @State private var isDeletingPoints = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack {
                Button(action: { dismiss() }) {
                    TopPanelBackButton(iconName: "chevron.backward")
                }
                .accessibilityIdentifier("vector.nav.back")
                    
                    Spacer()
                    
                    Button(action: {
                        undo()
                    }) {
                        TopPanelButton(iconName: "arrow.uturn.backward")
                    }
                    .disabled(!canAddPoints)
                    
                    Button(action: {
                        clear()
                    }) {
                        TopPanelButton(iconName: "arrow.circlepath")
                    }
                    .disabled(!canAddPoints)
                    
                    Button(action: {
                        redo()
                    }) {
                        TopPanelButton(iconName: "arrow.uturn.forward")
                    }
                    .disabled(!canAddPoints)
                    
                    Spacer()
                    
                    Button(action: {
                        isDeletingPoints.toggle()
                    }) {
                        Text(isDeletingPoints ? "Done" : "Delete")
                            .foregroundColor(.white)
                            .font(Font.system(size: 16).weight(.medium))
                            .frame(width: 60, height: 40)
                            .background(isDeletingPoints ? Color.green : Color.blue)
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("vector.toggleDelete")
                    .disabled(!canAddPoints)
                }
                
                GeometryReader { geometry in
                    Canvas { context, _ in
                        
                        if !splinePoints.isEmpty {
                            context.stroke(Path { path in
                                path.addLines(splinePoints)
                            }, with: .color(Color.red))
                        }
                        
                        if !points.isEmpty {
                            context.stroke(Path { path in
                                path.move(to: points.first!)
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }, with: .color(Color.black))
                        }
                        
                        for point in points {
                            context.fill(Path(ellipseIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)), with: .color(Color.black))
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .border(Color.blue, width: 3)
                    .background(Color.white)
                    .accessibilityIdentifier("vector.drawingCanvas")
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                if canAddPoints {
                                    let location = value.location
                                    if !isDeletingPoints {
                                        var closeIndex: Int?
                                        for (index, point) in points.enumerated() {
                                            if distanceBetween(location, point) < 20 {
                                                closeIndex = index
                                                break
                                            }
                                        }
                                        if let index = closeIndex {
                                            points.append(points[index])
                                        } else {
                                            points.append(location)
                                        }
                                        redoStack.removeAll()
                                        updateSpline()
                                    } else {
                                        if let index = points.indices.min(by: { distanceBetween(location, points[$0]) < distanceBetween(location, points[$1]) }) {
                                            points.remove(at: index)
                                            redoStack.removeAll()
                                            updateSpline()
                                        }
                                    }
                                }
                            }
                    )
                    
                }
                
                if canAddPoints {
                    Button(action: {
                        points.removeAll()
                        points.append(contentsOf: splinePoints)
                        splinePoints.removeAll()
                        undoStack.removeAll()
                        redoStack.removeAll()
                        canAddPoints = false
                    }) {
                        ConvertButton()
                    }
                } else {
                    Button(action: {
                        points.removeAll()
                        canAddPoints = true
                    }) {
                        DrawAnotherButton()
                    }
                }

        }
        .padding()
        .background(Color.black)
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
    
    func updateSpline() {
        splinePoints = splineInterpolation(points: points)
    }
    
    func splineInterpolation(points: [CGPoint]) -> [CGPoint] {
        var splinePoints: [CGPoint] = []
        
        if points.count < 2 {
            return splinePoints
        }
        
        for i in 0..<(points.count - 1) {
            let p0 = points[max(0, i - 1)]
            let p1 = points[i]
            let p2 = points[min(points.count - 1, i + 1)]
            let p3 = points[min(points.count - 1, i + 2)]
            
            for t in stride(from: 0, through: 1, by: 0.001) {
                let x = 0.5 * ((2 * p1.x) + (-p0.x + p2.x) * t + (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * pow(t, 2) + (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * pow(t, 3))
                let y = 0.5 * ((2 * p1.y) + (-p0.y + p2.y) * t + (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * pow(t, 2) + (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * pow(t, 3))
                
                splinePoints.append(CGPoint(x: x, y: y))
            }
        }
        
        return splinePoints
    }
    
    func undo() {
        guard let lastPoint = points.popLast() else { return }
        redoStack.append(lastPoint)
        updateSpline()
    }
    
    func redo() {
        guard let lastRedoPoint = redoStack.popLast() else { return }
        points.append(lastRedoPoint)
        updateSpline()
    }
    
    func clear() {
        undoStack = points
        points.removeAll()
        redoStack.removeAll()
        updateSpline()
    }
}

struct VectorView_Previews: PreviewProvider {
    static var previews: some View {
        VectorView()
    }
}

func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    let dx = point1.x - point2.x
    let dy = point1.y - point2.y
    return sqrt(dx * dx + dy * dy)
}
