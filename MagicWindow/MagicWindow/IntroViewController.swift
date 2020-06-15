import UIKit
import SVGKit


protocol IntroViewDelegate:class {
    func goToCamera()
    func goToTutorial()
}

class IntroViewController: UIViewController {
    
    weak var  delegate:IntroViewDelegate? = nil
    
    var _initFlg:Bool = false
    var initialImage:UIImage!
    var imageView:UIImageView!
    var _name:UILabel!
    
    var label:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        
        
        self.view.alpha = 0
        
        
        imageView = UIImageView()

        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight)
        //imageView.image = UIImage(named: "curated1")
        
        
        self.view.addSubview(imageView)
        
        

        
        
        let _cov = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
         _cov.alpha = 0.46
         _cov.backgroundColor = .black
         self.view.addSubview(_cov)
        
        var svgImageView: UIImageView = UIImageView()
        svgImageView.frame = CGRect(x: screenWidth/2-930/3/2, y: screenHeight - 330, width: 930/3, height: 460/3)
        let svgImage = SVGKImage(named: "magicsky_top")
        svgImage?.size = svgImageView.bounds.size
        svgImageView.image = svgImage?.uiImage
        
        self.view.addSubview(svgImageView)
        
        
        
        
        label = UILabel(frame: CGRect(x: 0, y: screenHeight-170, width: screenWidth, height: 77/3))
        label.font = UIFont(name: "Helvetica", size: 64/3)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "tap to create"
        self.view.addSubview(label)
        

        self.label.alpha = 1.0
        
        startBlink()
        /*
        _name = UILabel(frame: CGRect(x: 0, y: screenHeight-45, width: screenWidth, height: 50/3))
        _name.font = UIFont(name: "Helvetica-LightOblique", size: 42/3)
        _name.textAlignment = .center
        _name.textColor = .white
        self.view.addSubview(_name)
 */
        /*
        let _decBt = UIButton()
        
        _decBt.setTitle("CREATE", for: [])
        _decBt.setTitleColor(UIColor.white, for: [])
        //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
        _decBt.backgroundColor = .black
        _decBt.layer.cornerRadius = 24
        _decBt.frame = CGRect(x:(screenWidth-280)/2, y:screenHeight - 100, width:280, height:48)
        _decBt.addTarget(self, action: #selector(self.goToCamera), for: .touchUpInside)
        self.view.addSubview(_decBt)
 */
        
        
        let _decBt = UIButton()
        
        //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
        _decBt.backgroundColor = .clear
        _decBt.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight)
        _decBt.addTarget(self, action: #selector(self.goToCamera), for: .touchUpInside)
        self.view.addSubview(_decBt)
    }
    
    func startBlink(){
        
        UIView.animate(withDuration:1.6, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
            self.label.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration:1.6, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
                self.label.alpha = 1
            }, completion: { _ in
                self.startBlink()
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let _ = UserDefaults.standard.object(forKey: "num") as? Int {
            //labelに表示
            var _num = UserDefaults.standard.object(forKey: "num") as! Int
            
            if(_num == 1){
                _initFlg = true
            }
        }
    }
    public func initialize(img:UIImage,author:String){
        initialImage = img
        //print(img)
        //print(imageView)
        imageView.image = initialImage
        //_name.text = author

        self.view.alpha = 0
        UIView.animate(withDuration: 0.5, delay:0.5,animations: {
               self.view.alpha = 1
          }, completion: { (finished: Bool) in
          
          })
    }

    
    @objc func goToCamera(sender: UIButton!){
        if(_initFlg == true){
           //self.delegate?.goToCamera()
            
            self.delegate?.goToTutorial()
        }else{

            self.delegate?.goToTutorial()
        }
        //self.delegate?.goToCamera()
    }

}

