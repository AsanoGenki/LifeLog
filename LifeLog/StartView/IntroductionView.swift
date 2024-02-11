//
//  IntroductionView.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI

struct IntroductionView: View {
    @State private var pageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    @State private var showInputTitle = false
    var body: some View {
        TabView(selection: $pageIndex) {
            ForEach(pages) { page in
                VStack {
                    Spacer()
                    StartViewPage(page: page)
                    Spacer()
                    if page == pages.last {
                        NavigationLink(destination: InputEventTitle()) {
                            Text("let's give it a shot")
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                                .font(.system(size: 18))
                        }
                    }
                    Spacer()
                }
                .tag(page.tag)
            }
        }
        .animation(.easeInOut, value: pageIndex)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            dotAppearance.currentPageIndicatorTintColor = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
        .fullScreenCover(isPresented: $showInputTitle) {
            InputEventTitle()
        }
        .preferredColorScheme(.light)
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
