//
//  PremiumView.swift
//  LifeLog
//
//  Created by Genki on 11/29/23.
//

import SwiftUI
import StoreKit
import Lottie

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State var isLoading = false
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 14) {
                        Text("Optimize Time,\nRevolutionize Life.")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        LottieView(name: "relax")
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                            .padding(.vertical, -45)
                            .padding(.top, -75)
                        Text("Try 7 days free!")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                        Text("Customers who have already tried Premium are not eligible")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Spacer()
                                Text("Enhanced Experience")
                                    .fontWeight(.semibold)
                                Spacer()
                                Rectangle()
                                    .frame(width: 1, height: 60)
                                    .foregroundColor(.gray)
                                Text("Free")
                                    .frame(width: 80, height: 60)
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .cornerRadius(0, maskedCorners: [.layerMaxXMinYCorner])
                                Text("Pro")
                                    .fontWeight(.semibold)
                                    .frame(width: 80, height: 60)
                                    .foregroundColor(.white)
                                    .background(Color("gptPurple"))
                                    .cornerRadius(5, maskedCorners: [.layerMaxXMinYCorner])
                            }
                            Divider()
                                .background(Color(UIColor.tertiaryLabel))
                            CircleCrossItem(title: LocalizedStringKey("No Ads"))
                            CircleCrossItem(title: LocalizedStringKey("Unlimited Chart"))
                            TextItem(title: LocalizedStringKey("Image Capacity"), freeText: "150MB", proText: "∞")
                            CircleCrossItem(title: LocalizedStringKey("Unlimited Timer Item"))
                            LastCircleCrossItem(title: LocalizedStringKey("Expand Viewable Dates"))
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(UIColor.tertiaryLabel), lineWidth: 1)
                        )
                        HStack {
                            if let url = URL(string: "https://lifelog-app.studio.site/TermsOfUse") {
                                Link("Terms of use", destination: url)
                                    .font(.system(size: 13))
                            }
                            Spacer()
                            Text("Restore purchases")
                                .font(.system(size: 13))
                                .onTapGesture {
                                    Task {
                                        do {
                                            try await AppStore.sync()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                        }.foregroundColor(Color(UIColor.secondaryLabel))
                        Rectangle()
                            .foregroundStyle(Color("whiteBlack"))
                            .frame(height: 80)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .navigationBarItems(leading: Button(action: {
                        if !isLoading {
                            dismiss()
                        }
                    }, label: {
                        Image(systemName: "xmark")
                    }).foregroundColor(.primary))
                }
                VStack {
                    Spacer()
                    VStack {
                        if entitlementManager.hasPro {
                            Text("Subscribed")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: 55)
                                .background(Color.gray.cornerRadius(10))
                                .foregroundColor(.white)
                        } else {
                            ForEach(purchaseManager.products, id: \.self) { product in
                                Button {
                                    print(product.displayPrice)
                                    Task {
                                        do {
                                            isLoading = true
                                            try await purchaseManager.purchase(product)
                                            isLoading = false
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    Text("Subscribe now")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                        .background(Color("gptPurple").cornerRadius(10))
                                        .foregroundColor(.white)
                                }
                                Text("7 days free, then \(product.displayPrice)/ month")
                            }
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                    .background(Color("whiteBlack"))
                }
                .task {
                    Task {
                        do {
                            try await purchaseManager.loadProducts()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView().progressViewStyle(.circular)
                }
            }
        }
    }
}

struct PartlyRoundedCornerView: UIViewRepresentable {
    let cornerRadius: CGFloat
    let maskedCorners: CACornerMask
    func makeUIView(context: UIViewRepresentableContext<PartlyRoundedCornerView>) -> UIView {
        let uiView = UIView()
        uiView.layer.cornerRadius = cornerRadius
        uiView.layer.maskedCorners = maskedCorners
        uiView.backgroundColor = .white
        return uiView
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PartlyRoundedCornerView>) {
    }
}
struct PartlyRoundedCornerModifier: ViewModifier {
    let cornerRadius: CGFloat
    let maskedCorners: CACornerMask
    func body(content: Content) -> some View {
        content.mask(PartlyRoundedCornerView(cornerRadius: self.cornerRadius, maskedCorners: self.maskedCorners))
    }
}
struct LottieView: UIViewRepresentable {
    var name: String
    var animationView = LottieAnimationView()
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    }
}
