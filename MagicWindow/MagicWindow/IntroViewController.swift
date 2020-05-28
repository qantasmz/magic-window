import UIKit


protocol IntroViewDelegate:class {
    func goToCamera()
}

class IntroViewController: UIViewController {
    
    weak var  delegate:IntroViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        
        

        
        
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight)
        imageView.image = UIImage(named: "defsky.jpg")
        
        
        self.view.addSubview(imageView)
        
        
        let _decBt = UIButton()
        
        _decBt.setTitle("CREATE", for: [])
        _decBt.setTitleColor(UIColor.white, for: [])
        //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
        _decBt.backgroundColor = .black
        _decBt.layer.cornerRadius = 24
        _decBt.frame = CGRect(x:(screenWidth-280)/2, y:screenHeight - 100, width:280, height:48)
        _decBt.addTarget(self, action: #selector(self.goToCamera), for: .touchUpInside)
        self.view.addSubview(_decBt)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @objc func goToCamera(sender: UIButton!){
        self.delegate?.goToCamera()
    }

}

