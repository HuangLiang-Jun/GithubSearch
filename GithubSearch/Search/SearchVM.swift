//
//  SearchVM.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation
import RxCocoa
import RxSwift

class SearchVM: ViewModelType, SearchApi {
    
    struct Input {
        let keyword: AnyObserver<String>
    }

    struct Output {
        let reloadData: Driver<Void>
        let users: BehaviorRelay<[UserModel]>
        let nextPage: BehaviorRelay<Int?>
        let showError: Signal<String>
        let isLoading: Driver<Bool>
        let loadingState: BehaviorRelay<Bool>
    }
    
    var input: Input
    var output: Output
    
    private let keywordObserve = PublishSubject<String>()
    private let reloadData = PublishSubject<Void>()
    private let showError = PublishSubject<String>()
    private let isLoading = BehaviorRelay(value: false)
    private let users: BehaviorRelay<[UserModel]> = BehaviorRelay(value: [])
    private let nextPage: BehaviorRelay<Int?> = BehaviorRelay(value: 1)
    private let disposeBag = DisposeBag()
    
    private var keyword: String = ""
    
    init() {
        input = Input(keyword: keywordObserve.asObserver())
        output = Output(reloadData: reloadData.asDriver(onErrorJustReturn: ()),
                        users: users,
                        nextPage: nextPage,
                        showError: showError.asSignal(onErrorJustReturn: "unknown error"),
                        isLoading: isLoading.asDriver(onErrorJustReturn: false),
                        loadingState: isLoading)
        bind()
    }
    
    private func bind() {
        users
            .bind(onNext: { [weak self] _ in
                self?.reloadData.onNext(())
            })
            .disposed(by: disposeBag)
        
        keywordObserve
            .subscribe(onNext: { [weak self] text in
                self?.keyword = text
            }).disposed(by: disposeBag)
    }
    
    func searchUser() {
        guard !keyword.isEmpty else { return }
        isLoading.accept(true)
        nextPage.accept(1)
        self.searchUsers(key: keyword, page: nextPage.value ?? 1) { [weak self] data, hasNext, error in
            guard let self = self else { return }
            self.isLoading.accept(false)
            if let error = error {
                self.errorHandler(errorMsg: error.localizedDescription)
                return
            }
            guard let data = data else { return }
            self.users.accept(data)
            self.updateNextpage(hasNext: hasNext)
        }
    }
    
    func getNextPage() {
        guard !keyword.isEmpty, nextPage.value != nil else { return }
        self.searchUsers(key: keyword, page: nextPage.value!) { [weak self] data, hasNext, error in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(errorMsg: error.localizedDescription)
                return
            }
            guard let data = data else { return }
            self.users.accept(self.users.value + data)
            self.updateNextpage(hasNext: hasNext)
        }
    }
    
    private func updateNextpage(hasNext: Bool) {
        guard hasNext, let nextpage = nextPage.value else {
            nextPage.accept(nil)
            return
        }
        nextPage.accept(nextpage + 1)
    }
    
    private func errorHandler(errorMsg: String) {
        showError.onNext(errorMsg)
        users.accept([])
        updateNextpage(hasNext: false)
    }
}
