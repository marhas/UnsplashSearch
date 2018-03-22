//
//  ViewController.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ImageSearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var searchInfoLabel: UILabel!
    @IBOutlet weak var pageInfoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorMessageLabel: UILabel!

    enum NavigationDirection {
        case next, previous, first, last
    }

    var searchController: UISearchController!
    var apiService: ApiService!
    var searchResults = [Int: SearchResult]()
    var currentPageIndex = 0
    var searchWasCancelled = false
    var searchString = ""

    var totalPages: Int {
        return currentSearchResult?.totalPages ?? 0
    }

    var currentSearchResult: SearchResult? {
        get {
            return searchResults[currentPageIndex]
        }
        set {
            searchResults[currentPageIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSearchController()

        self.setupCollectionView()

        verifyUnsplashToken() {
            self.apiService = ApiService()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if searchResults.isEmpty {
            searchController.searchBar.becomeFirstResponder()
        }
    }

    @IBAction func firstButtonPressed(_ sender: Any) {
        loadSearchResults(navigationDirection: .first)
    }

    @IBAction func previousButtonPressed(_ sender: Any) {
        loadSearchResults(navigationDirection: .previous)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        loadSearchResults(navigationDirection: .next)
    }

    @IBAction func lastButtonPressed(_ sender: Any) {
        loadSearchResults(navigationDirection: .last)
    }

    @IBAction func unwindToSearch(segue: UIStoryboardSegue) { }

    private func verifyUnsplashToken(completion: (() -> Void)?) {
        if ApiService.unsplashApiToken == nil {
            let alertController = UIAlertController(title: "Unsplash token missing", message: "You need to enter an Unsplash API token, for more details, see https://unsplash.com/developers", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
                if let unsplashApiToken = alertController.textFields?[0].text {
                    ApiService.unsplashApiToken = unsplashApiToken
                    completion?()
                }
            })
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "Unsplash API token"
                textField.keyboardType = .default
            })
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }

    }

    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: "ThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let imageSize = floor((collectionView.contentSize.width - 3) / 3)
        flowLayout.itemSize = CGSize(width: imageSize, height: imageSize)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        collectionView.collectionViewLayout = flowLayout
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        navigationItem.titleView = searchBar
        searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
    }

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
                nextButton.isEnabled = false
                previousButton.isEnabled = false
                firstButton.isEnabled = false
                lastButton.isEnabled = false
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

    private func loadSearchResults(navigationDirection : NavigationDirection) {
        let searchResultsUrl: URL?
        switch navigationDirection {
        case .next:
            searchResultsUrl = currentSearchResult?.nextResult
        case .previous:
            searchResultsUrl = currentSearchResult?.previousResult
        case .first:
            searchResultsUrl = currentSearchResult?.firstResult
        case .last:
            searchResultsUrl = currentSearchResult?.lastResult
        }
        guard let searchUrl = searchResultsUrl else { return }
        let searchResource = SearchResources.createSearchResource(url: searchUrl)
        load(searchResource: searchResource)
    }

    private func load(searchResource: Resource<SearchResult>) {
        isLoading = true
        apiService.load(resource: searchResource) { [unowned self] searchResult, error in
            guard let searchResult = searchResult else {
                if let error = error, case ApiError.requestFailed(let errorMessage) = error {
                    DispatchQueue.main.async {
                        self.errorMessageLabel.text = errorMessage
                        self.errorMessageLabel.isHidden = false
                        self.searchInfoLabel.isHidden = true
                        self.pageInfoLabel.isHidden = true
                        self.isLoading = false
                    }
                }
                return
            }

            DispatchQueue.main.async { [unowned self] in
                self.currentPageIndex = searchResource.url.page - 1
                self.currentSearchResult = searchResult
                self.collectionView.reloadData()
                self.updateSearchResultLabels(with: searchResult)
                self.updateNavigationButtons(with: searchResult)
                self.isLoading = false
            }
        }
    }

    private func updateSearchResultLabels(with searchResult: SearchResult) {
        self.searchInfoLabel.text = "\(searchResult.total) matching images"
        self.pageInfoLabel.text = "Page \(currentPageIndex + 1)"
        self.searchInfoLabel.isHidden = false
        self.pageInfoLabel.isHidden = false
        self.errorMessageLabel.isHidden = true
    }

    private func updateNavigationButtons(with searchResult: SearchResult) {
        nextButton.isEnabled = searchResult.nextResult != nil
        previousButton.isEnabled = searchResult.previousResult != nil
        firstButton.isEnabled = searchResult.firstResult != nil
        lastButton.isEnabled = searchResult.lastResult != nil
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard   let imageUrl = currentSearchResult?.images?[indexPath.row].imageUrl,
                let thumbnailCell = collectionView.cellForItem(at: indexPath) as? ThumbnailCollectionViewCell,
                let placeholderImage = thumbnailCell.imageView.image
        else {
            assert(false)
            return
        }
        let imageDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
        imageDetailViewController.configure(imageUrl: imageUrl, placeholderImage: placeholderImage)
        imageDetailViewController.imageUrl = imageUrl
        imageDetailViewController.transitioningDelegate = imageDetailViewController
        present(imageDetailViewController, animated: true, completion: nil)
    }
}

extension ImageSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCollectionViewCell

        if let imageUrl = currentSearchResult?.images?[indexPath.row].thumbnailUrl {
            thumbnailCell.imageUrl = imageUrl
        }
        return thumbnailCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSearchResult?.images?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        if searchWasCancelled {
            searchString = ""
            searchWasCancelled = false
        } else {
            searchBar.text = searchString
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchWasCancelled = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ImageSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != searchString else { return }  // Nothing changed. This can happen ie when the search field resigns first responder.

        searchString = searchController.searchBar.text ?? ""

        guard searchString.count > 3 else { return }

        searchResults.removeAll()
        currentPageIndex = 0

        guard let searchResource = SearchResources.createSearchResource(for: searchString) else { return }
        load(searchResource: searchResource)
    }
}
