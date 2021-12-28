//
//  NoticeViewController.swift
//  remote-config-a_b-testing
//
//  Created by Jacob Ko on 2021/12/28.
//

import UIKit

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

