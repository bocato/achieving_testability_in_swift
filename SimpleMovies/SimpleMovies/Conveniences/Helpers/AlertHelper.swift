import UIKit

protocol AlertHelperProtocol {
    static func presentChoiceAlert(
        from controller: UIViewController,
        title: String?,
        message: String,
        yesAction: @escaping () -> Void,
        noAction: (() -> Void)?
    )
    static func presentSimpleAlert(
        from controller: UIViewController,
        title: String?,
        message: String
    )
}
extension AlertHelperProtocol {
    static func presentChoiceAlert(
        from controller: UIViewController,
        title: String? = nil,
        message: String,
        yesAction: @escaping () -> Void,
        noAction: (() -> Void)? = nil
    ) {
        self.presentChoiceAlert(
            from: controller,
            title: title,
            message: message,
            yesAction: yesAction,
            noAction: noAction
        )
    }
    static func presentSimpleAlert(
        from controller: UIViewController,
        title: String? = nil,
        message: String
    ) {
        self.presentSimpleAlert(
            from: controller,
            title: title,
            message: message
        )
    }
}

enum AlertHelper: AlertHelperProtocol {
    
    static func presentChoiceAlert(
        from controller: UIViewController,
        title: String? = nil,
        message: String,
        yesAction: @escaping () -> Void,
        noAction: (() -> Void)? = nil
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(
            .init(
                title: "Yes",
                style: .default,
                handler: { _ in
                    yesAction()
                    alert.dismiss(animated: true, completion: nil)
                }
            )
        )
        
        alert.addAction(
            .init(
                title: "No",
                style: .default,
                handler: { _ in
                    noAction?()
                    alert.dismiss(animated: true, completion: nil)
                }
            )
        )
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
        
    }
    
    static func presentSimpleAlert(
        from controller: UIViewController,
        title: String? = nil,
        message: String
    ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
}
