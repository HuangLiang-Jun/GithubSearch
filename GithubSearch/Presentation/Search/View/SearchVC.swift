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
enum ListSection {
    case idle
    case data
    case empty
}

class SearchVC: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: SearchVM
    
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
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.register(UserCell.self, forCellWithReuseIdentifier: "cell")
        cv.delegate = self
        cv.backgroundView = noDataLabel
        cv.backgroundColor = .clear
        return cv
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Please Enter KeyWord"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource = UICollectionViewDiffableDataSource<ListSection, User>(collectionView: collectionView) { collectionView, indexPath, user -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? UserCell
        cell?.configure(with: user)
        return cell
    }
    
    private var snapshot = NSDiffableDataSourceSnapshot<ListSection, User>()
    
    init(viewModel: SearchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            .bind(to: viewModel.input.queryBinder)
            .disposed(by: disposeBag)
        
        searchBar.rx
            .searchButtonClicked
            .do(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .bind(to: viewModel.input.searchDidTapBinder)
            .disposed(by: disposeBag)
        
        viewModel.output
            .reloadDriver
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.noDataLabel.isHidden = !self.viewModel.usersRelay.value.isEmpty
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.output
            .isLoadingDriver
            .drive (onNext: { [weak self] isLoading in
                if isLoading {
                    self?.indicatorView.startAnimating()
                } else {
                    self?.indicatorView.stopAnimating()
                }
            }).disposed(by: disposeBag)

        viewModel.output
            .showErrorSignal
            .emit(onNext: { [weak self] errorMsg in
                self?.showErrorAlert(message: errorMsg)
            }).disposed(by: disposeBag)
        
        viewModel.output
            .usersDriver
            .map({ users -> NSDiffableDataSourceSnapshot<ListSection, User> in
                var snapshot = NSDiffableDataSourceSnapshot<ListSection, User>()
                snapshot.appendSections([.data])
                snapshot.appendItems(users)
                return snapshot
            })
            .drive { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }
            .disposed(by: disposeBag) 
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
        if indexPath.row == viewModel.usersRelay.value.count - 1 {
            viewModel.getNextPage()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width * 0.29
        return CGSize(width: size, height: size + 20)
    }
}
