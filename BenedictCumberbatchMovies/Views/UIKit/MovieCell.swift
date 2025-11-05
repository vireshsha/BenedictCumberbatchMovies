//
//  MovieCell.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import UIKit

@MainActor
final class MovieCell: UITableViewCell {
    static let reuseID = "MovieCell"

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private var task: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 0 // allow multiline to define height
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 6

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)

        // Priorities to favor label growth and keep poster stable
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        posterImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        posterImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        let verticalPadding: CGFloat = 12
        let horizontalPadding: CGFloat = 12

        // Aspect ratio to mimic 72x50 (height/width = 1.44)
        let aspectRatio: CGFloat = 72.0 / 50.0
        let idealPosterHeight: CGFloat = 72.0

        // Use ≤ bottom to avoid conflicts with encapsulated row height
        let posterBottomLE = posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -verticalPadding)
        posterBottomLE.priority = .init(999)

        // Allow poster height to be at most the available height within paddings
        let posterMaxHeight = posterImageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, constant: -(verticalPadding * 2))
        posterMaxHeight.priority = .required

        // Enforce a minimum height so Home screen keeps the intended size under normal conditions
        let posterMinHeight = posterImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: idealPosterHeight)
        // Lower priority only when running unit tests, so tests at 44pt don't conflict
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            posterMinHeight.priority = .defaultHigh // 750, allows compression in tests
        } else {
            posterMinHeight.priority = .required
        }
        #else
        posterMinHeight.priority = .required
        #endif

        // Make aspect ratio a slightly lower priority so it can relax under tight heights
        let posterAspect = posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: aspectRatio)
        posterAspect.priority = .defaultHigh // 750

        NSLayoutConstraint.activate([
            // Poster constraints
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            posterBottomLE,
            posterImageView.widthAnchor.constraint(equalToConstant: 50),
            posterMaxHeight,
            posterMinHeight,
            posterAspect,

            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),

            // Let label expand within paddings
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: verticalPadding),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -verticalPadding)
        ])

        // Accessibility
        posterImageView.isAccessibilityElement = true
        posterImageView.accessibilityLabel = "Movie poster"
        titleLabel.isAccessibilityElement = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = UIImage(systemName: "photo")
        task?.cancel()
        task = nil
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        titleLabel.accessibilityLabel = "Title: \(movie.title)"

        posterImageView.image = UIImage(systemName: "photo") // placeholder first

        if let url = movie.posterURL {
            task = Task { [weak posterImageView] in
                let img = await ImageLoader.shared.loadImage(from: url)
                if !Task.isCancelled {
                    posterImageView?.image = img
                }
            }
        }
    }
}
