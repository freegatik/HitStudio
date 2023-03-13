//
//  WelcomeView.swift
//  HitStudio
//
//  Created by freegatik on 13.03.2023.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var app: AppDependencies

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Image("starting-screen-background")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .frame(maxWidth: 150, maxHeight: 40)
                        .foregroundColor(Color.blue)
                        .overlay(
                            Text(LocalizedStringKey("welcome.poweredBy"))
                                .foregroundColor(.white)
                                .font(Font.system(size: 18).weight(.medium))
                        )
                    
                    Text(LocalizedStringKey("welcome.title"))
                        .font(Font.system(size: 36).weight(.bold))
                        .foregroundColor(Color.white)
                        .accessibilityIdentifier("welcome.title")
                    
                    Text(LocalizedStringKey("welcome.subtitle"))
                        .font(Font.system(size: 18).weight(.medium))
                        .foregroundColor(Color.white)
                        .lineSpacing(5)
                    
                    HStack {
                        NavigationLink(destination: GalleryView(editImageViewModel: app.editorViewModel)) {
                            Text(LocalizedStringKey("welcome.imageEditor"))
                                .foregroundColor(.white)
                                .font(Font.system(size: 16).weight(.medium))
                                .frame(maxWidth: 500, maxHeight: 60)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .accessibilityIdentifier("welcome.nav.imageEditor")
                        NavigationLink(destination: VectorView()) {
                            Text(LocalizedStringKey("welcome.vectorEditor"))
                                .foregroundColor(.white)
                                .font(Font.system(size: 16).weight(.medium))
                                .frame(maxWidth: 500, maxHeight: 60)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .accessibilityIdentifier("welcome.nav.vectorEditor")
                        NavigationLink(destination: CubeView()) {
                            Text(LocalizedStringKey("welcome.cube3d"))
                                .foregroundColor(.white)
                                .font(Font.system(size: 16).weight(.medium))
                                .frame(maxWidth: 500, maxHeight: 60)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .accessibilityIdentifier("welcome.nav.cube3d")
                    }
                    .padding(.bottom, 70)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            app.analytics.trackScreen("welcome")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppDependencies())
    }
}
