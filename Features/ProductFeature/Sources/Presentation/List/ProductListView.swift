import CoreKit
import FavoriteKitInterface
import ProductFeatureInterface
import SwiftUI

struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    private let favoriteStore: any FavoriteStore

    init(viewModel: ProductListViewModel, favoriteStore: any FavoriteStore) {
        _viewModel = State(initialValue: viewModel)
        self.favoriteStore = favoriteStore
    }

    var body: some View {
        content
            // 상단 행을 콘텐츠에 둬 목록과 함께 스크롤되게 한다
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.onAppear() }
            // 추가 조회 실패는 목록을 지우지 않는다. 다이얼로그로만 알린다
            .alert(
                "불러오지 못했습니다",
                isPresented: Binding(
                    get: { viewModel.loadMoreFailure != nil },
                    set: { if !$0 { viewModel.loadMoreFailure = nil } }
                )
            ) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.loadMoreFailure ?? "")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .failed(message):
            ErrorStateView(message: message) {
                Task { await viewModel.retry() }
            }
        case let .loaded(products):
            list(products)
        }
    }

    private func list(_ products: [ProductSummary]) -> some View {
        ScrollView {
            LazyVStack(spacing: Metrics.sectionSpacing) {
                header
                LazyVGrid(columns: viewModel.layout.columns, spacing: Metrics.rowSpacing) {
                    ForEach(products) { product in
                        cell(product)
                    }
                }
                if viewModel.hasMore {
                    LoadMoreButton(isLoading: viewModel.isLoadingMore) {
                        Task { await viewModel.loadMore() }
                    }
                }
            }
            .padding(.horizontal, Metrics.horizontalPadding)
            .padding(.top, Metrics.contentTopPadding)
        }
    }

    private var header: some View {
        HStack {
            Text("총 \(viewModel.total)개")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                viewModel.layout.toggle()
            } label: {
                Image(systemName: viewModel.layout.toggleSymbol)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    /// 셀 전체는 onTapGesture, 찜은 Button
    /// NavigationLink 로 감싸면 링크가 탭을 독점해 안쪽 버튼이 눌리지 않는다
    private func cell(_ product: ProductSummary) -> some View {
        ProductCell(
            product: product,
            layout: viewModel.layout,
            isFavorite: favoriteStore.ids.contains(product.id),
            toggleFavorite: { Task { await favoriteStore.toggle(product.id) } }
        )
        .contentShape(Rectangle())
        .onTapGesture { viewModel.select(product) }
    }
}

private enum Metrics {
    static let horizontalPadding: CGFloat = 20
    static let contentTopPadding: CGFloat = 12
    static let sectionSpacing: CGFloat = 20
    static let rowSpacing: CGFloat = 20
}
