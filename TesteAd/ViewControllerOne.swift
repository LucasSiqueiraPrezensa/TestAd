import UIKit
import GoogleMobileAds

class ViewControllerOne: UIViewController {

    private var adLoader: AdLoader?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        loadCustomNative()
    }

    private func loadCustomNative() {

        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1

        adLoader = AdLoader(
            adUnitID: "/32352161/formatos/ShortzVideo",
            rootViewController: self,
            adTypes: [.customNative],
            options: [multipleAdsOptions]
        )

        adLoader?.delegate = self

        let request = AdManagerRequest()

        request.customTargeting = [
            "tvg_pos": "SHORTZ"
        ]

        adLoader?.load(request)
    }
}

extension ViewControllerOne: CustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return ["12420626"]
    }
    
    func adLoader(
        _ adLoader: AdLoader,
        didReceive customNativeAd: CustomNativeAd
    ) {

        print("✅ Custom Native loaded")

        let mediaContent = customNativeAd.mediaContent

        let aspectRatio = mediaContent.aspectRatio

        print("📐 Aspect Ratio:", aspectRatio)

        let width = view.bounds.width

        // altura = largura / aspectRatio
        let height = width / CGFloat(aspectRatio)

        print("📏 Calculated height:", height)

        let mediaView = MediaView(frame: CGRect(
            x: 0,
            y: 100,
            width: width,
            height: height
        ))

        mediaView.mediaContent = mediaContent
        mediaView.backgroundColor = .black

        view.addSubview(mediaView)

        customNativeAd.recordImpression()

        print("✅ MediaView renderizado")
    }
    
    func adLoader2(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
        print("✅ Custom Native loaded")
        print("ASSETS:", customNativeAd.availableAssetKeys)

        let mediaView = MediaView(frame: CGRect(
            x: 0,
            y: 100,
            width: view.bounds.width,
            height: 300
        ))

        mediaView.backgroundColor = .black

        // AQUI
        mediaView.mediaContent = customNativeAd.mediaContent

        view.addSubview(mediaView)

        customNativeAd.recordImpression()

        print("✅ MediaView renderizado")
    }

    func adLoader(
        _ adLoader: AdLoader,
        didFailToReceiveAdWithError error: Error
    ) {
        print("❌ ERROR:", error.localizedDescription)
    }
}
