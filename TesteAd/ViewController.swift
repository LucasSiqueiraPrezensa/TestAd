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

        view.backgroundColor = .black

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

// MARK: - CustomNativeAdLoaderDelegate

extension ViewController: CustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return ["12420626"]
    }

    func adLoader(
        _ adLoader: AdLoader,
        didReceive customNativeAd: CustomNativeAd
    ) {
        print("✅ Custom Native loaded")

        customAds.append(customNativeAd)

        carousel.reloadData()
    }

    func adLoader(
        _ adLoader: AdLoader,
        didFailToReceiveAdWithError error: Error
    ) {
        print("❌ ERROR:", error.localizedDescription)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return customAds.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AdCarouselCell.identifier,
            for: indexPath
        ) as? AdCarouselCell else {

            return UICollectionViewCell()
        }

        let ad = customAds[indexPath.item]

        cell.configure(with: ad)

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
    }
}

// MARK: - Cell

final class AdCarouselCell: UICollectionViewCell {
    static let identifier = "AdCarouselCell"
    
    private let mediaView: MediaView = {
        let view = MediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        return view
    }()

    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .black
        contentView.addSubview(mediaView)
        contentView.addSubview(gradientView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with ad: CustomNativeAd) {
        mediaView.mediaContent = ad.mediaContent

        // asset customizado
        if let title = ad.string(forKey: "Title") {
            titleLabel.text = title
        } else {
            titleLabel.text = "Publicidade"
        }

        ad.recordImpression()
    }
}
