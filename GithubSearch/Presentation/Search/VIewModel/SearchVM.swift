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
        let queryBinder: Binder<String?>
        let searchDidTapBinder: Binder<Void>
        let loadMoreBinder: Binder<Void>
    }

    struct Output {
        let reloadDriver: Driver<Void>
        let usersDriver: Driver<[User]>
        let showErrorSignal: Signal<String>
        let isLoadingDriver: Driver<Bool>
    }
    
    var input: Input
    var output: Output
    
    private let queryRelay = BehaviorRelay<String?>(value: nil)
    private let reloadDataRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String>()
    private let searchDidTapRelay = PublishRelay<Void>()
    private let isLoadingRelay = BehaviorRelay(value: false)
    let usersRelay: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    private let paginationRelay: BehaviorRelay<Pagination<User>?> = BehaviorRelay(value: nil)
    private let loadMoreRelay: PublishRelay<Void> = PublishRelay()
    private var currentPage: Int = 0
    private var incompleteResults: Bool? = nil
    private let disposeBag = DisposeBag()
    
    private let searchUserUseCase: SearchUsersUseCase
    
    init(searchUserUseCase: SearchUsersUseCase) {
        self.searchUserUseCase = searchUserUseCase
        
        input = Input(queryBinder: queryRelay.asBinder(),
                      searchDidTapBinder: searchDidTapRelay.asBinder(),
                      loadMoreBinder: loadMoreRelay.asBinder())
        
        output = Output(reloadDriver: reloadDataRelay.asDriver(onErrorJustReturn: ()),
                        usersDriver: usersRelay.asDriver(),
                        showErrorSignal: errorRelay.asSignal(onErrorJustReturn: "unknown error"),
                        isLoadingDriver: isLoadingRelay.asDriver())
        bind()
    }
    
    private func bind() {
        usersRelay
            .bind(onNext: { [weak self] _ in
                self?.reloadDataRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        searchDidTapRelay
            .subscribe { [weak self] _ in
                self?.incompleteResults = nil
                self?.searchUser()
            }
            .disposed(by: disposeBag)
    }
    
    private func searchUser() {
        guard let query = queryRelay.value, !query.isEmpty else { return }
        isLoadingRelay.accept(true)
        Task {
            do {
                let data = try await searchUserUseCase.execute(query: query, page: currentPage + 1)
                isLoadingRelay.accept(false)
                incompleteResults = data.incompleteResults
                currentPage += 1
                usersRelay.accept(data.items)
            } catch {
                isLoadingRelay.accept(false)
                errorHandler(errorMsg: error.localizedDescription)
            }
        }
    }

    func getNextPage() {
        guard incompleteResults == false else { return }
        searchUser()
    }
    
    private func errorHandler(errorMsg: String) {
        debugPrint(errorMsg)
        errorRelay.accept(errorMsg)
    }
}
