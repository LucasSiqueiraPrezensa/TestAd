import UIKit
import GoogleMobileAds

class ViewController: UIViewController {

    // MARK: - Properties

    private var adLoader: AdLoader?
    private var customAds: [CustomNativeAd] = []

    private lazy var carousel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0

        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        collection.isPrefetchingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .black

        collection.register(
            AdCarouselCell.self,
            forCellWithReuseIdentifier: AdCarouselCell.identifier
        )

        collection.dataSource = self
        collection.delegate = self

        return collection
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCarousel()
        loadCustomNative()
    }

    // MARK: - Setup

    private func setupCarousel() {
        view.addSubview(carousel)

        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.topAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Ads

    private func loadCustomNative() {
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        let videoOptions = VideoOptions()
        videoOptions.areCustomControlsRequested = true

        adLoader = AdLoader(
            adUnitID: "/32352161/formatos/ShortzVideo",
            rootViewController: self,
            adTypes: [.customNative],
            options: [multipleAdsOptions, videoOptions]
        )

        adLoader?.delegate = self

        let request = AdManagerRequest()

        request.customTargeting = [
            "tvg_pos": "SHORTZ"
        ]

        adLoader?.load(request)
    }
}

// MARK: - CustomNativeAdLoaderDelegate

extension ViewController: CustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return ["12420626"]
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
        printDebugAd(customNativeAd)
        
        let mediaContent = customNativeAd.mediaContent
        let hasVideo = mediaContent.hasVideoContent
        let hasImage = mediaContent.mainImage != nil && mediaContent.aspectRatio > 0
        let hasRenderableMedia = hasVideo || hasImage

        guard hasRenderableMedia else {
            print("❌ Sem mídia renderizável")
            return
        }

        customAds.append(customNativeAd)

        DispatchQueue.main.async {
            self.carousel.reloadData()
        }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("❌ ERROR:", error.localizedDescription)
    }
    
    private func printDebugAd(_ customNativeAd: CustomNativeAd) {
        print("\n------ ASSETS ------")
        for key in customNativeAd.availableAssetKeys {
            if let value = customNativeAd.string(forKey: key) {
                print("📝 \(key): \(value)")
            } else if let image = customNativeAd.image(forKey: key) {
                print("🖼️ \(key): \(image)")
            } else {
                print("📦 \(key): 🛠️")
            }
        }

        let mediaContent = customNativeAd.mediaContent

        print("\n🎥 hasVideoContent:", mediaContent.hasVideoContent)
        print("📐 aspectRatio:", mediaContent.aspectRatio)
        print("🖼️ mainImage:", mediaContent.mainImage as Any)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customAds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCarouselCell.identifier, for: indexPath) as? AdCarouselCell else {
            return UICollectionViewCell()
        }

        let ad = customAds[indexPath.item]
        cell.configure(with: ad)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
    }
}
