//
//  SearchVC.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchVC: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = SearchVM()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 24
        flowLayout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(UserCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.backgroundView = noDataLabel
        return view
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "no users"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40)
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { content in
            self.collectionView.reloadData()
        }
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        
        searchBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bind() {
        searchBar.rx
            .text
            .orEmpty
            .bind(to: viewModel.input.keyword)
            .disposed(by: disposeBag)
        
        searchBar.rx
            .searchButtonClicked
            .bind(onNext: { [weak self] in
                self?.view.endEditing(true)
                self?.viewModel.searchUser()
            }).disposed(by: disposeBag)
        
        viewModel.output
            .reloadData
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.noDataLabel.isHidden = !self.viewModel.output.users.value.isEmpty
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.output
            .isLoading
            .drive (onNext: { [weak self] isLoading in
                guard let self = self else { return }
                self.collectionView.isHidden = isLoading
                if isLoading {
                    self.indicatorView.startAnimating()
                } else {
                    self.indicatorView.stopAnimating()
                }
            }).disposed(by: disposeBag)

        viewModel.output
            .showError
            .drive(onNext: { [weak self] errorMsg in
                self?.showErrorAlert(message: errorMsg)
            }).disposed(by: disposeBag)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate
extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard viewModel.output.nextPage.value != nil else { return }
        if indexPath.row == viewModel.output.users.value.count - 1 {
            viewModel.getNextPage()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource
extension SearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.users.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserCell
        cell.configure(with: viewModel.output.users.value[indexPath.row])
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width * 0.29
        return CGSize(width: size, height: size + 20)
    }
}
