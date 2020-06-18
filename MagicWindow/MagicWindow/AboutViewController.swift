import UIKit
import SVGKit

import Firebase

protocol AboutViewDelegate:class {
    
}



class AboutViewController: UIViewController {

    weak var  delegate:AboutViewDelegate? = nil
    
    var _label:UITextView!
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    

    self.view.backgroundColor = .white
    
    var svgImageView: UIImageView
    var svgImage: SVGKImage

    let closeButton = UIButton()

    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 70/3, height: 70/3)
    svgImage = SVGKImage(named: "peke2")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    closeButton.frame = CGRect(x:20, y:40,width:70/3, height:70/3)

    closeButton.addSubview(svgImageView)
    closeButton.imageView?.contentMode = .scaleAspectFit
    closeButton.addTarget(self, action: #selector(tapClose(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(closeButton)
    
    
    var _hnum:Float = 0
    
    
    
    _hnum = 640
    let core0:UIView = UIView(frame: CGRect(x: 0, y: screenHeight/2 - CGFloat(_hnum)/2, width: screenWidth, height: CGFloat(_hnum)))
    
    
    let logoImage:UIImage = UIImage(named:"magic")!
    let logoImageView = UIImageView(image:logoImage)
    let rect:CGRect = CGRect(x: screenWidth/2-844/3/2, y: 160-65, width: 844/3, height: 411/3)
     logoImageView.contentMode = .scaleAspectFill
    logoImageView.frame = rect;
    core0.addSubview(logoImageView)
    
    

    var _txt:String

    var attrs:[NSAttributedString.Key : UIFont]
    
    var baseString:NSMutableAttributedString
    var attributedString:NSMutableAttributedString

        baseString = NSMutableAttributedString(string:"")
    
    _txt = "is a camera experience created by "
    attrs = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 72/3)!]
   attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
     _txt = "FAKE ARTISTS, "
    attrs = [NSAttributedString.Key.font :  UIFont(name: "Helvetica-Bold", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    
    baseString.append(attributedString)
    
    _txt = "in collaboration with "
    attrs = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 72/3)!]
    attributedString = NSMutableAttributedString(string:_txt, attributes:attrs)
    
    baseString.append(attributedString)
    
     _txt = "BASSDRUM"
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
    
    let originString:NSString = baseString.mutableString
    
    baseString.addAttribute(.link,value: "https://www.fakeartists.studio/",range: NSString(string: originString).range(of: "FAKE ARTISTS"))
    baseString.addAttribute(.link,value: "https://bassdrum.org/",range: NSString(string: originString).range(of: "BASSDRUM"))
    baseString.addAttribute(.link,value: "http://dosomethinggood.co/",range: NSString(string: originString).range(of: "Do Something Good"))


    /*
     baseString.addAttribute(.underlineStyle,value: UIColor.black,range: NSString(string: originString).range(of: "FAKE ARTISTS"))
    baseString.addAttribute(.underlineStyle,value: UIColor.black,range: NSString(string: originString).range(of: "BASSDRUM"))
    baseString.addAttribute(.underlineStyle,value: UIColor.black,range: NSString(string: originString).range(of: "Do Something Good"))
    */
    
    _label = UITextView()
    _label.backgroundColor = .clear
    _label.isEditable = false
    //_label.numberOfLines = 0
    _label.textAlignment = .justified
    _label.frame = CGRect(x: screenWidth/2-900/3/2, y: 340-50, width: 900/3, height: 300)
    let linkAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.underlineColor: UIColor.clear,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    _label.linkTextAttributes = linkAttributes
    _label.attributedText = baseString
    _label.textAlignment = .justified
    core0.addSubview(_label)
    self.view.addSubview(core0)
    
    /*
    let cpImage:UIImage = UIImage(named:"logos")!
    let cpImageView = UIImageView(image:cpImage)
    let rectCp:CGRect = CGRect(x: screenWidth/2-914/3/2, y: screenHeight-209/3-60, width: 914/3, height: 209/3)
     cpImageView.contentMode = .scaleAspectFill
    cpImageView.frame = rectCp;
    self.view.addSubview(cpImageView)
 */
    

    self.setNeedsStatusBarAppearanceUpdate()
  }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
         
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let _logTitle = "about"
    Analytics.logEvent(_logTitle, parameters: [
        AnalyticsParameterItemID: "id-\(_logTitle)",
        AnalyticsParameterItemName: _logTitle,
    AnalyticsParameterContentType: "cont"
    ])
  }
    
    
    @objc func tapClose(_ sender : UIButton){
        dismiss(animated: true, completion: nil)
    }
}
