# 🧪 remoteConfig-ABTesting-iOS-practice

| `isHidden = false`                                                                                                                                 |                                                                 `isHidden = true`                                                                  |
| :------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img width="300" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/147554007-929aaf4a-7ff9-4e94-a9ba-46220d6a5f92.png"> | <img width="300" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/147554371-1d56b322-8ab6-4ab6-817c-be10e231dbe3.png"> |

## 📌 기능 상세

- Firebase remoteConfig 를 통해서 공지사항 팝을 보이게하거나, 내용을 원격으로 수정하는것을 연습합니다

- A/B testing 을 사용하여 A,B 안의 alert 창의 내용을 50% random 으로 보이게 설정합니다

## 👉 Pod library

### 🔷 Firebase RemoteConfig, Analytics

> RemoteConfig 1.6.0 in CocoaPods - https://cocoapods.org/pods/RemoteConfig

> FirebaseAnalytics 8.10.0 in CocoaPods - https://cocoapods.org/pods/FirebaseAnalytics

- Firebase RemoteConfig, A/B testing 의 사용을 위한 pod 라이브러리 설치

#### 설치

`pod init`

```ruby
  # Pods for remote-config-a_b-testing
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Analytics'
end
```

`pod install`

```swift
// in AppDelegate.swift
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Firebase init
		FirebaseApp.configure()
		return true
	}
```

#### 사용법

## 🔑 Check Point !

<!-- ### 🔷 UI Structure -->

### 🔷 UI Code

```swift
// in NoticeViewController.swift

class NoticeViewController: UIViewController {
	var noticeContents: (title: String, detail: String, date: String)?

	// MARK: IBOutlet
	@IBOutlet weak var noticeView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!

	// MARK: LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Raius, backgroundColor 설정
		noticeView.layer.cornerRadius = 6
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		guard let noticeContents = noticeContents else { return }
		self.titleLabel.text = noticeContents.title
		self.detailLabel.text = noticeContents.detail
		self.dateLabel.text = noticeContents.date
	}

	// MARK: Actions
	@IBAction func tabDoneBtn(_ sender: UIButton) {
		// 클릭하면 화면이 닫히게 하는 action
		self.dismiss(animated: true, completion: nil)
	}
}

```

<!-- ### 🔷 Model -->

### 🔷 Remote Config 로 팝업 제어하기

원격 구성은 Key, Value 형태하며, 기본값을 업데이트 하는 방식입니다. ViewController 에서 원격 controller 의 값을 불러 와서 noticeViewController 의 값을 제어 하는 구성입니다

#### 기본 viewController 에 원격 구성 플렛폼을 가지고 오기

원격 구성은 key, value의 형태의 dictionary 타입입니다. property 파일을 생성해서 default 값을 설정해 줍니다

![image](https://user-images.githubusercontent.com/28912774/147515489-01f7ad60-eaab-4f2a-81ed-2742deffa6de.png)

- 그다음에 ViewController 에서 FirebaseRemoteConfig 와 Plist 를 연결시킵니다

```swift
// in ViewController.swift

import FirebaseRemoteConfig

class ViewController: UIViewController {

	// 객체 생성
	var remoteConfig: RemoteConfig?

	// MARK: LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()

		remoteConfig = RemoteConfig.remoteConfig()

		let setting = RemoteConfigSettings()
		// 테스트를 위해서 새로운 값을 fetch 하는 interval 을 최소화 해서 최대한 자주 원격 데이터를 가지고 올수 있게 interval 을 0으로 설정함
		setting.minimumFetchInterval = 0
		remoteConfig?.configSettings = setting
		// 기본값을 Plist와 연결하여 설정
		remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
	}
}

```

#### Firebase console 과 연결하기

- Firebase web console 에서 Remote config 메뉴에 구성 만들기를 실행 합니다

- 첫 번째 매개 변수 만들기 실행: property list 를 추가한것과 동일하게 console 에도 추가 시킵니다

![image](https://user-images.githubusercontent.com/28912774/147515898-2089c71a-1687-4667-9709-ba6e1d7e2682.png)

```swift
// in ViewController.swift

// RemoteConfig
extension ViewController {

	// MARK: Methods
	// Notice fetch 하기 (가져오기)
	func getNotice() {
		guard let remoteConfig = remoteConfig else { return }

		remoteConfig.fetch {[weak self] status, _ in
			if status == .success {
				remoteConfig.activate(completion: nil)
			} else {
				print("ERROR: Config not fetched")
			}

			guard let self = self else { return }
			// isHidden 이 false 일때 보여질때면
			if !self.isNoticeHidden(remoteConfig) {
				let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
				noticeVC.modalPresentationStyle = .custom
				noticeVC.modalTransitionStyle = .crossDissolve

				// optional 이기 때문에 없으면 ""
				// 참고 firebase 에서 참조 값을 가지고 올때 \\ 가 2번 되서 fetch 되기때문에 swift 에서 값을 인식하지 못하는 case 가 발생되기 때문에 따로 형식을 지정해줘야 함 (그래야 여러줄을 입력하더라도 잘 인식하게 됨)
				let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
				let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
				let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")

				// 각각의 값을 noticeVC 에 넣어줌
				noticeVC.noticeContents = (title: title, detail: detail, date: date)
				self.present(noticeVC, animated: true, completion: nil)
			}
		}
	}

	// 공지사항 숨기기 method
	func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
		return remoteConfig["isHidden"].boolValue
	}
}
```

web console 에서 공지 사항이 작동하게 매개 변수 값을 변경하고 `viewWillAppear` 에서 `getNotice()` method 가 실행하게 되면 공지사항 팝업이 나타 나게 됩니다

```swift
// in ViewController.swift

override func viewWillAppear(_ animated: Bool) {
	super.viewWillAppear(animated)
	getNotice()
}
```

![image](https://user-images.githubusercontent.com/28912774/147516808-cd5e09d2-8a13-4524-ada8-a685fec7d138.png)

<img width="300" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/147516844-de21515c-bc91-407d-b44b-003a9bfeb06a.png">

#### value 조건 설정하기

- Remote Config 값이 특정 사용자에게만 보일 수 있게도 설정할 수 있습니다

아래는 기기 system 언어가 english 일경우에 title 이 영어로 나타 낼 수 있게 하는 예시 설정 입니다

- web console 에서 매개 변수 값에서 조건을 추가 시키고 게시 합니다

![image](https://user-images.githubusercontent.com/28912774/147519066-70755b2d-7ac5-4b76-a0e7-779bd267bb6b.png)

기기 설정에서 기본언어를 English 로 변경하게 되면 영어로 된 Notice title 을 확인 할 수 있습니다

<img width="300" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/147519584-14779ae0-c2c2-48e3-91ea-429bfbce8a00.png">

### 🔷 A/B Testing 으로 팝업 제어하기

별도 공지사항이 없고, App 사용이 원활할 경우 Event Alert 을 보여 주는 예시 코드 입니다

만약 A, B 의 각각의 다른 문구를 사용했을 경우 어떠한 방식이 사용자가 더 참여를 많이 하는지 알아 볼 수 있습니다

#### A/B Testing 실험 만들기

- web console 에서 A/B Testing 를 선택하면, 실험을 어떻게 구성할지 실험만들기에서 원격 구성을 선택합니다.

![image](https://user-images.githubusercontent.com/28912774/147519952-892ec063-a67c-4872-bde6-592707b6a7e8.png)

- 사용자의 50% 만 보일수 있게 타겟팅 설정을 합니다

![image](https://user-images.githubusercontent.com/28912774/147520012-c1509a66-1db6-434f-9195-9ffabeb112fa.png)

- 목표는 이미 설정된 수익률, 광고수익, 유지등을 설정 할 수 있으나, 얼마나 클릭을 많이 하는지 보기 위함이기 때문에 custom 으로 promotion_alert 이라고 생성해 줍니다

- 변형에서는 값설정인데, 기준의 되는 값과 변경되는 비교값 (Variant A) 을 정할 수 있습니다

![image](https://user-images.githubusercontent.com/28912774/147520556-b6bb4214-f8b8-4ba1-9d5c-e0951068f282.png)

- 실험을 저장하고, 실험 시작을 실행합니다

- Remote Config 의 가게 되면 message key, value 생성 되었음을 확인합니다.

![image](https://user-images.githubusercontent.com/28912774/147520852-6a1e1952-4eb2-485b-a796-f10e29c0bd4a.png)

```swift
// in ViewController.swift

// A/B Testing method
extension ViewController {
	func showEventAlert() {
		guard let remoteConfig = remoteConfig else { return }

		remoteConfig.fetch { [weak self] status, _ in
			if status == .success {
				remoteConfig.activate(completion: nil)
			} else {
				print("Config not fetched")
			}

			// message 가져기
			let message = remoteConfig["message"].stringValue ?? ""
			// confrimAction
			let confirmAction = UIAlertAction(title: "확인하기", style: .default) { _ in
				// Google Anlytics : confirm btn 을 누를때 마다 google anlytics 에서 기록하게 만듬
				Analytics.logEvent("promotio_alert", parameters: nil)
			}
			let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
			let alertController = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)
			alertController.addAction(confirmAction)
			alertController.addAction(cancelAction)

			// 화면에 alertController 입력
			self?.present(alertController, animated: true, completion: nil)
		}
	}
}

```

- 버튼이 눌릴때 마다 google analytics 에 기록될 수 있게 확인하기 (xcode 에서 product -> Scheme -> Edit Scheme 에서 Run 의 Arguments passed on Launch 에서 아래의 값을 추가함)

![image](https://user-images.githubusercontent.com/28912774/147538283-0e597952-ba11-4b45-9ecc-dbe4a18e116c.png)

<img width="300" alt="스크린샷" src="https://user-images.githubusercontent.com/28912774/147538801-5199a8ab-b516-4a32-9de2-ec8373e09fd4.png">

확인하기를 누르게 되면 web console 에서 `DebugView` 의 `promotion_alert` 의 event 가 생성됨을 확인할 수 있습니다

![image](https://user-images.githubusercontent.com/28912774/147539029-25ad5cb1-5af6-433f-ab43-e4209df4020a.png)

- 50% 의 확률로 메세지가 변하게 됨이 잘 되는것을 확인하기 위해서는 `AppDelegate` 에서 debug mode 에서 확인 할 수 있습니다. (FIS 인증 토큰을 통해 확인하기)

```swift
// in AppDelegate.swift

import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		// Firebase init
		FirebaseApp.configure()

		// firebase 가 각각의 기기에 인증한 token 값을 console 에서 확인하기
		Installations.installations().authTokenForcingRefresh(true) { result , error in
			if let error = error {
				print("ERROR")
				return
			}
			guard let result = result else { return }
			print("Installtion auth token : \(result.authToken) 임")
		}
		return true
	}

```

위 코드 작성 후에 console 참에 auth token 이 생성됨을 확인하고, 복사합니다

![image](https://user-images.githubusercontent.com/28912774/147540030-0507a1ae-0f7a-4ecf-8d56-8c2a41fd1010.png)

- web console 에서 remote Config 에서 생성된 실험에서 테스트 기기 에 FIS 인증 토큰을 붙여 넣기 합니다

![image](https://user-images.githubusercontent.com/28912774/147540451-f0152713-4acd-4368-bb8a-1f17fa9e7485.png)

위와 같이 변수를 기준, Variant A 로 바꾸게 되면 고정된 alert 창이 뜨게 되어 조절 할 수 있습니다

> Describing check point in details in Jacob's DevLog - https://jacobko.info/firebaseios/ios-firebase-03/

<!-- ## ❌ Error Check Point

### 🔶 -->

<!-- xcode Mark template -->

<!--
// MARK: IBOutlet
// MARK: LifeCycle
// MARK: Actions
// MARK: Methods
// MARK: Extensions
-->

<!-- <img width="300" alt="스크린샷" src=""> -->

---

🔶 🔷 📌 🔑 👉

## 🗃 Reference

Jacob's DevLog - [https://jacobko.info/firebaseios/ios-firebase-03/](https://jacobko.info/firebaseios/ios-firebase-03/)

해리의 유목코딩 - [https://medium.com/harrythegreat/android-remote-config-%EC%9E%98-%ED%99%9C%EC%9A%A9%ED%95%98%EA%B8%B0-f8b04ef2645a](https://medium.com/harrythegreat/android-remote-config-%EC%9E%98-%ED%99%9C%EC%9A%A9%ED%95%98%EA%B8%B0-f8b04ef2645a)

Firebase Tutorial: iOS A/B Testing - [https://www.raywenderlich.com/20974552-firebase-tutorial-ios-a-b-testing](https://www.raywenderlich.com/20974552-firebase-tutorial-ios-a-b-testing)

fastcampus - [https://fastcampus.co.kr/dev_online_iosappfinal](https://fastcampus.co.kr/dev_online_iosappfinal)
