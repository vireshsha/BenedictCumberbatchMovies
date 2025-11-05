//
//  HomeViewController.swift
//  BenedictCumberbatchMovies
//
//  Fixed for dependency injection and programmatic launch
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private weak var coordinator: AppCoordinator?

    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activity = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    // Data snapshot derived from state
    private var movies: [Movie] = []

    init(viewModel: HomeViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Benedict Cumberbatch Movies"
        setupUI()
        render(state: viewModel.state)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Kick off loading on first appearance if not already loaded/loading
        if case .idle = viewModel.state {
            Task { [weak self] in
                await self?.viewModel.loadMovies()
                await MainActor.run {
                    self?.render(state: self?.viewModel.state ?? .idle)
                }
            }
        }
    }

    private func setupUI() {
        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.accessibilityIdentifier = "moviesTable"
        // Enable automatic row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96

        // Activity
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true

        // Message label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        view.addSubview(tableView)
        view.addSubview(activity)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 24),
            messageLabel.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -24)
        ])
    }

    private func render(state: ViewState<[Movie]>) {
        switch state {
        case .idle:
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = "Welcome"
            activity.stopAnimating()

        case .loading:
            tableView.isHidden = true
            messageLabel.isHidden = true
            activity.startAnimating()

        case .loaded(let movies):
            self.movies = movies
            tableView.reloadData()
            tableView.isHidden = false
            messageLabel.isHidden = true
            activity.stopAnimating()

        case .empty:
            self.movies = []
            tableView.reloadData()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = "No movies found."
            activity.stopAnimating()

        case .error(let message):
            self.movies = []
            tableView.reloadData()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = "Error: \(message)"
            activity.stopAnimating()
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseID, for: indexPath) as? MovieCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "fallback")
        }
        cell.configure(with: movies[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        coordinator?.showDetail(movie: movie)
    }
}
