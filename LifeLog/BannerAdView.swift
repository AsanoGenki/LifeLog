//
//  BannerAdView.swift
//  LifeLog
//
//  Created by Genki on 12/8/23.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    let adUnit: AdUnit
    let adFormat: AdFormat
    @State var adStatus: AdStatus = .loading
    @State var showAd: Bool = true
    var body: some View {
        HStack {
            if showAd {
                if adStatus != .failure {
                    ZStack {
                        BannerViewController(adUnitID: adUnit.unitID, adSize: adFormat.adSize, adStatus: $adStatus)
                            .frame(width: adFormat.size.width, height: adFormat.size.height)
                            .zIndex(1)
                        Text("Ad is loading...")
                            .zIndex(0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct BannerViewController: UIViewControllerRepresentable {
    let adUnitID: String
    let adSize: GADAdSize
    @Binding var adStatus: AdStatus
    class Coordinator: NSObject, GADBannerViewDelegate {
        var bannerViewController: BannerViewController
                init(bannerViewController: BannerViewController) {
            self.bannerViewController = bannerViewController
        }
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            bannerViewController.adStatus = .failure
        }
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            bannerViewController.adStatus = .success
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(bannerViewController: self)
    }
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let request = GADRequest()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let view = GADBannerView(adSize: self.adSize)
        view.delegate = context.coordinator
        view.adUnitID = self.adUnitID
        view.rootViewController = viewController
        view.load(request)
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: self.adSize.size)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

enum AdStatus {
    case loading
    case success
    case failure
}

enum AdUnit {
    case mainView
    case subView
    case anotherView
    var unitID: String {
        switch self {
        case .mainView: return "ca-app-pub-9856694313731412/8192499952"
        case .subView: return "ca-app-pub-9856694313731412/8192499952"
        case .anotherView: return "ca-app-pub-9856694313731412/8192499952"
        }
    }
}

enum AdFormat {
    case largeBanner
    case mediumRectangle
    case adaptiveBanner
    var adSize: GADAdSize {
        switch self {
        case .largeBanner: return GADAdSizeLargeBanner
        case .mediumRectangle: return GADAdSizeMediumRectangle
        case .adaptiveBanner:
            return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(
                UIScreen.main.bounds.size.width)
        }
    }
    var size: CGSize {
        adSize.size
    }
}
