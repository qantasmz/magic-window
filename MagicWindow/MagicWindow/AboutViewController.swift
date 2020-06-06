import UIKit
import SVGKit


protocol AboutViewDelegate:class {
    
}



class AboutViewController: UIViewController {

    weak var  delegate:AboutViewDelegate? = nil
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    

    self.view.backgroundColor = .white
    
    var svgImageView: UIImageView
    var svgImage: SVGKImage

    let closeButton = UIButton()

    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 135/3, height: 135/3)
    svgImage = SVGKImage(named: "peke2")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    closeButton.frame = CGRect(x:15, y:50,width:135/3, height:135/3)

    closeButton.addSubview(svgImageView)
    closeButton.imageView?.contentMode = .scaleAspectFit
    closeButton.addTarget(self, action: #selector(tapClose(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(closeButton)
    
    
    let logoImage:UIImage = UIImage(named:"magic")!
    let logoImageView = UIImageView(image:logoImage)
    let rect:CGRect = CGRect(x: screenWidth/2-930/3/2, y: 160, width: 930/3, height: 460/3)
     logoImageView.contentMode = .scaleAspectFill
    logoImageView.frame = rect;
    self.view.addSubview(logoImageView)
    
    

    var _txt:String

    var attrs:[NSAttributedString.Key : UIFont]
    
    var baseString:NSMutableAttributedString
    var attributedString:NSMutableAttributedString

        baseString = NSMutableAttributedString(string:"")
    
    _txt = "is a camera experience created by "
    attrs = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 72/3)!]
   attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
     _txt = "Fake Artists, "
    attrs = [NSAttributedString.Key.font :  UIFont(name: "Helvetica-Bold", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
    _txt = "in collaboration with "
    attrs = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
     _txt = "Bassdrum"
    attrs = [NSAttributedString.Key.font :  UIFont(name: "Helvetica-Bold", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    
    baseString.append(attributedString)
    
    
    _txt = "\n\nThis project has been developed with the support of "
    attrs = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
     _txt = "Do Something Good"
    attrs = [NSAttributedString.Key.font :  UIFont(name: "Helvetica-Bold", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    
    baseString.append(attributedString)
    
    let _label = UILabel()
    _label.numberOfLines = 0
    _label.textAlignment = .justified
    _label.frame = CGRect(x: screenWidth/2-980/3/2, y: 340, width: 980/3, height: 300)
    _label.attributedText = baseString
    self.view.addSubview(_label)
    
    
    let cpImage:UIImage = UIImage(named:"logos")!
    let cpImageView = UIImageView(image:cpImage)
    let rectCp:CGRect = CGRect(x: screenWidth/2-914/3/2, y: screenHeight-209/3-60, width: 914/3, height: 209/3)
     cpImageView.contentMode = .scaleAspectFill
    cpImageView.frame = rectCp;
    self.view.addSubview(cpImageView)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    
    
    @objc func tapClose(_ sender : UIButton){
        dismiss(animated: true, completion: nil)
    }
}
