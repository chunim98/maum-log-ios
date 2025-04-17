![header](https://github.com/user-attachments/assets/dad0d43a-d66d-410c-827d-c149e596c8a3)

## 다운로드
[![AppStore](https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white)](https://apps.apple.com/kr/app/%EB%A7%88%EC%9D%8C%EB%A1%9D-%EB%AA%A8%EB%91%90%EC%9D%98-%EB%A7%88%EC%9D%8C%EC%9D%84-%EC%9C%84%ED%95%9C-%EB%B3%B5%EC%95%BD-%EA%B8%B0%EB%A1%9D-%EC%95%B1/id6661016604)

<br/>

## 개요
단 3번의 터치로 빠르게 복약 기록!

모두의 마음과 시간은 소중하니까!

"마음록"은 복약 후 부작용 및 증상을 쉽고 빠르게 기록할 수 있는 복약 기록 앱입니다.

**개발 기간: 2024.07.26 ~ 2024.08.24**

<br/>

## 사용 기술
**디자인 패턴은 MVVM-C를 사용했습니다.**

| 이름 | 목적 |
| --- | --- |
| RxSwift | UIKit 환경에서 반응형 프로그래밍과 추적이 쉬운 데이터 흐름을 구현합니다. |
| Combine | UIKit 환경에서 반응형 프로그래밍과 추적이 쉬운 데이터 흐름을 구현합니다. |
| RxDataSources | RxCocoa로 TableView 바인딩 시 애니메이션을 적용합니다. |
| CoreData | 투약 기록에 관한 데이터를 관리합니다. |
| SnapKit | AutoLayout 제약조건 코드의 가독성을 개선합니다. |

<br/>

## 코드 컨벤션

- 더 이상 상속되지 않는 클래스는 final 키워드를 사용합니다.
- 강제 언래핑은 사용하지 않습니다. 단, 별도의 nil 체크 로직이 존재할 경우에는 주석과 함께 제한적으로 사용이 가능합니다.
- IUO(Implicitly Unwrapped Optional) 타입의 경우 로직상 nil이 아닌 것이 확실할 경우에만 제한적으로 사용이 가능합니다.
- 5단어 이상의 이름은 지양합니다.
- 이하의 약어만 허용합니다.
  > ViewController → VC
  > 
  > ViewModel → VM
  > 
  > TableView → TV
  > 
  > CollectionView → CV

<br/>

## 문제 해결
[🔗 문제 해결 사례(리팩토링 이전)](https://axiomatic-mambo-9a8.notion.site/180b946392fe80dc8950ed09335e5ff9?pvs=4)

<br/>

## 지원
[🔗 사용 설명서](https://axiomatic-mambo-9a8.notion.site/54e65995a2674035808368b00005a63e?pvs=4)

[✉️ jjingeo1230@gmail.com](mailto:jjingeo1230@gmail.com)
