import UIKit

protocol ShareViewDelegate:class {
}


class ShareViewController: UIViewController {

    
    weak var  delegate:ShareViewDelegate? = nil
    
    
  override func viewDidLoad() {
    super.viewDidLoad()

    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    

}

