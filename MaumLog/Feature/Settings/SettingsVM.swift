//
//  SettingsVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/10/24.
//

import UIKit

final class SettingsVM {
    let sectionHeader = ["기록", "기타"]
    
    func deleteAllLog(view: UIViewController) {
        
        let textFieldAlert = {
            let alert = UIAlertController(title: String(localized: "초기화"), message: String(localized: "다음 단어를 정확히 입력해주세요.\n\"삭제\""), preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = String(localized: "삭제")
                textField.textAlignment = .center
            }
            
            
            let success = UIAlertAction(title: String(localized: "초기화"), style: .default) { _ in
                let text = alert.textFields?[0].text ?? ""
                if text == "삭제" {
                    LogDataManager.shared.deleteAll {
                        HapticManager.shared.occurSuccess()
                        view.presentAcceptAlert(
                            title: String(localized: "초기화 완료"),
                            message: String(localized: "모든 기록이 삭제되었습니다.\n앱을 다시 실행해주세요."))
                    }
                }else{
                    view.presentAcceptAlert(
                        title: String(localized: "초기화 실패"),
                        message: String(localized: "잘못된 입력입니다.\n처음부터 다시 시도해주세요."))
                }
            }
            success.setValue(UIColor.systemRed, forKey: "titleTextColor")

            
            let cancel = UIAlertAction(title: String(localized: "취소"), style: .cancel) { _ in }
            
            
            alert.addAction(success)
            alert.addAction(cancel)
            
            view.present(alert, animated: true, completion: nil)
        }
        
        
        view.presentAlert(
            title: String(localized: "경고!"),
            message: String(localized: "모든 기록이 삭제됩니다.\n정말로 계속할까요?"),
            acceptTitle: String(localized: "초기화"),
            acceptTask: textFieldAlert)

    }

}
