//
//  ViewController.swift
//  remote-config-a_b-testing
//
//  Created by Jacob Ko on 2021/12/28.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		getNotice()
	}
}

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
			} else {
				self.showEventAlert()
			}
		}
	}
	
	// 공지사항 숨기기 method
	func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
		return remoteConfig["isHidden"].boolValue
	}
}

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

// MARK: IBOutlet

// MARK: Actions
// MARK: Extensions
