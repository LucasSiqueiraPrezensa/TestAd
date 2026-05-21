import UIKit
import GoogleMobileAds

final class ViewControllerFluid: UIViewController {
    private var bannerView: AdManagerBannerView!
    private var bannerHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupBanner()
        loadAd()
    }

    private func setupBanner() {

        // MARK: - Banner Fluid
        bannerView = AdManagerBannerView(adSize: AdSizeFluid)
        bannerView.delegate = self

        // Define largura explícita para anúncios fluid
        var frame = bannerView.frame
        frame.size.width = view.bounds.width
        bannerView.frame = frame

        // MARK: - Multi size (Fluid + Banner)
        bannerView.validAdSizes = [
            nsValue(for: AdSizeFluid),
            nsValue(for: AdSizeBanner)
        ]

        // MARK: - IDs de teste / configuração
        bannerView.adUnitID = "/32352161/formatos/ShortzVideo"
        bannerView.rootViewController = self

        // Delegate para acompanhar mudança de tamanho
        bannerView.adSizeDelegate = self
        bannerView.backgroundColor = .red

        // AutoLayout
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        bannerHeightConstraint = bannerView.heightAnchor.constraint(equalTo: self.view.heightAnchor)

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bannerHeightConstraint
        ])
    }

    private func loadAd() {

        let request = AdManagerRequest()

        // Targeting
        request.customTargeting = [
            "tvg_pos": "SHORTZ"
        ]

        bannerView.load(request)
    }
}

// MARK: - GADAdSizeDelegate

extension ViewControllerFluid: AdSizeDelegate {
    func adView(
        _ bannerView: BannerView,
        willChangeAdSizeTo adSize: AdSize
    ) {

        let width = adSize.size.width
        let height = adSize.size.height

        print("Tamanho do anúncio:")
        print("width: \(width)")
        print("height: \(height)")
    }
}

extension ViewControllerFluid: BannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("✅ Ad received")
    }

    func bannerView(
        _ bannerView: BannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        print("❌ Ad failed")
        print(error.localizedDescription)
    }
}
