import UIKit
import GoogleMobileAds

final class AdCarouselCell: UICollectionViewCell {

    static let identifier = "AdCarouselCell"

    // MARK: - Views

    private let mediaView: MediaView = {
        let view = MediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
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

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .black
        contentView.backgroundColor = .black

        contentView.addSubview(mediaView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(loadingView)

        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40),

            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mediaView.mediaContent = nil
        loadingView.stopAnimating()
    }

    // MARK: - Configure
    
    func configure(with ad: CustomNativeAd) {
        let mediaContent = ad.mediaContent

        let hasVideo = mediaContent.hasVideoContent
        let hasImage = mediaContent.mainImage != nil

        if hasVideo || hasImage {
            loadingView.startAnimating()
            mediaView.mediaContent = mediaContent
            mediaView.isHidden = false
        } else {
            mediaView.isHidden = true
        }

        renderTitle(with: ad)

        // Só faz autoplay/loop se houver vídeo
        if hasVideo {
            mediaContent.videoController.delegate = self
        }
        
        // remove loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.loadingView.stopAnimating()
        }

        ad.recordImpression()
    }
    
    private func renderTitle(with ad: CustomNativeAd) {
        let possibleTextKeys = [
            "Title",
            "Headline",
            "title",
            "headline",
            "Body",
            "body",
            "Description",
            "description",
            "Subtitle",
            "subtitle",
            "CTA",
            "CTA_TYPE",
            "CallToAction",
            "call_to_action"
        ]
        
        for key in possibleTextKeys {
            if let value = ad.string(forKey: key)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !value.isEmpty {
                titleLabel.text = value
                return
            }
        }

        titleLabel.text = "Publicidade"
    }
}

// MARK: - VideoControllerDelegate

extension AdCarouselCell: VideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            videoController.play()
        }
    }
}
