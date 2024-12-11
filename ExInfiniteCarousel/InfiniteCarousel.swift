//
//  InfiniteCarousel.swift
//  ExInfiniteCarousel
//
//  Created by 심성곤 on 12/11/24.
//

import SwiftUI

// https://calliek.tistory.com/63
// https://velog.io/@jujube0/SwiftUI로-네이버웹툰-상단-배너-만들기
/// 무한 스크롤 + 타이머
struct InfiniteCarousel: View {
    /// 순환배열
    @State var items: [Color] = [.red, .green, .blue]
    /// 타이머
    @State var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    /// 현재 인덱스
    @State private var currentIndex: Int = 0
    /// 드래그중 여부
    @State private var isDragging = false
    
    var body: some View {
        TabView(selection: $currentIndex) {
            
            // 순환 리스트에서 첫 번째와 마지막 색을 추가
            ForEach(-1..<items.count + 1, id: \.self) { i in
                
                let item = items[i < 0 ? items.count - 1 : (i >= items.count ? 0 : i)]
                item
                    .tag(i) // 현재 인덱스를 구분하기 위한 태그
                
            } //: ForEach
            .ignoresSafeArea()
            
        } //: Tabview
        .ignoresSafeArea()
        .tabViewStyle(.page(indexDisplayMode: .never)) // 기본 인디케이터 숨김
        // https://stackoverflow.com/a/79163904
        // 드래그 시 타이머 초기화가 안되서 gesture -> simultaneousGesture 수정
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in // 드래그 중 타이머 중지
                    isDragging = true
                    timer.upstream.connect().cancel()
                }
                .onEnded { _ in // 드래그 종료 타이머 활성화
                    isDragging = false
                    getInfiniteScrollIndex()
                    timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
                }
        )
        .onChange(of: currentIndex) { _, _ in
            if !isDragging { // 드래그 중이 아닐 경우에만 페이지 세팅
                getInfiniteScrollIndex() // 무한 스크롤 구현
            }
        } //: onChange
        .onReceive(timer) { _ in
            // 타이머 가동 시 인덱스 하나씩 옮김
            withAnimation(.easeIn) {
                currentIndex += 1
            }
        }
    } //: Body
    
    /// 무한 스크롤 구현
    private func getInfiniteScrollIndex() {
        
        if currentIndex == items.count {
            // 처음으로 갔을 때 끝쪽으로 이동 (딜레이 주지 않으면 애니메이션이 부자연스럽게 빠르게 변경됨)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex = 0
            }
        } else if currentIndex < 0 {
            // 마지막으로 갔을 때 첫쪽으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex = items.count - 1
            }
        }
    }
} //: View

#Preview {
    InfiniteCarousel()
}
