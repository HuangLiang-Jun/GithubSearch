//
//  SearchVM.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation
import RxCocoa
import RxSwift

class SearchVM: ViewModelType {
    
    struct Input {
        let keyword: AnyObserver<String>
    }

    struct Output {
        let reloadData: Driver<Void>
        let users: BehaviorRelay<[UserModel]>
        let nextPage: BehaviorRelay<Int?>
        let showError: Driver<String>
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
    private let nextPage: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()
    
    private var keyword: String = ""
    
    init() {
        input = Input(keyword: keywordObserve.asObserver())
        output = Output(reloadData: reloadData.asDriver(onErrorJustReturn: ()),
                        users: users,
                        nextPage: nextPage,
                        showError: showError.asDriver(onErrorJustReturn: "unknow error"),
                        isLoading: isLoading.asDriver(onErrorJustReturn: false),
                        loadingState: isLoading)
        bind()
    }
    
    private func bind() {
        keywordObserve
            .subscribe(onNext: { [weak self] text in
                self?.keyword = text
            }).disposed(by: disposeBag)
    }
    
    func searchUser() {
        guard !keyword.isEmpty else { return }
        isLoading.accept(true)
        output.nextPage.accept(1)
        SearchApi.searchUser(key: keyword) { [weak self] data, hasNext, error in
            guard let self = self else { return }
            self.isLoading.accept(false)
            if let error = error {
                self.errorHandler(errorMsg: error.localizedDescription)
                return
            }
            guard let data = data else { return }
            self.output.users.accept(data)
            self.updateNextpage(hasNext: hasNext)
            self.reloadData.onNext(())
        }
    }
    
    func getNextPage() {
        guard !keyword.isEmpty else { return }
        SearchApi.searchUser(key: keyword, page: nextPage.value!) { [weak self] data, hasNext, error in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(errorMsg: error.localizedDescription)
                return
            }
            guard let data = data else { return }
            self.output.users.accept(self.output.users.value + data)
            self.updateNextpage(hasNext: hasNext)
            self.reloadData.onNext(())
        }
    }
    
    private func updateNextpage(hasNext: Bool) {
        guard hasNext, let nextpage = output.nextPage.value else {
            output.nextPage.accept(nil)
            return
        }
        output.nextPage.accept(nextpage + 1)
    }
    
    private func errorHandler(errorMsg: String) {
        showError.onNext(errorMsg)
        output.users.accept([])
        updateNextpage(hasNext: false)
        reloadData.onNext(())
    }
}
