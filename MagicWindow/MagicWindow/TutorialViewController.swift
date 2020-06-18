import UIKit
import SVGKit

import Firebase

protocol TutorialViewDelegate:class {
    
    func goToCamera()
}



class TutorialViewController: UIViewController, UIScrollViewDelegate {

    var pt0:SVGKImage!
    var pt1:SVGKImage!
    var pt2:SVGKImage!
    var footerImage: UIImageView!
    weak var  delegate:TutorialViewDelegate? = nil
    var scrollView:UIScrollView!
    
    var tap:UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    var rect: CGSize
    let _offSet:Float = 150
    
    scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    scrollView.contentSize = CGSize(width: screenWidth*3, height: screenHeight)
    
    scrollView.isPagingEnabled = true
    
    var _hnum:Float = 0
    
    
    let view0:UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    view0.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    
    let gradient0 = CAGradientLayer()

    gradient0.frame = view.bounds
    gradient0.colors = [UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1).cgColor, UIColor(red: 209/255, green: 87/255, blue: 255/255, alpha: 1).cgColor]

    view0.layer.insertSublayer(gradient0, at: 0)
    
    
    _hnum = 600 + 270/3
    let core0:UIView = UIView(frame: CGRect(x: 0, y: screenHeight/2 - CGFloat(_hnum)/2, width: screenWidth, height: CGFloat(_hnum)))
    
    let label = UILabel(frame: CGRect(x: 0, y: 250 - 150, width: screenWidth, height: 114/3))
    label.font = UIFont(name: "Helvetica", size: 95/3)
    label.textAlignment = .center
    label.textColor = .white
    label.text = "welcome to"
    core0.addSubview(label)
    
    var svgImageView: UIImageView
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-843/3/2, y: 325 - 150, width: 843/3, height: 425/3)
    let svgImage0 = SVGKImage(named: "logo_pp")
    svgImage0!.size = svgImageView.bounds.size
    svgImageView.image = svgImage0?.uiImage
    
    core0.addSubview(svgImageView)
    
    let lbl0 = UILabel(frame: CGRect(x: 0, y: 540 - 165, width: screenWidth, height: 270/3))
    lbl0.font = UIFont(name: "Helvetica", size: 65/3)
    lbl0.textAlignment = .center
    lbl0.textColor = .white
    lbl0.numberOfLines = 0
    lbl0.text = "turn the sky into a playground\nfor your creativity"
    
    
    rect = lbl0.sizeThatFits(CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
    lbl0.frame = CGRect(x: 0, y: 540 - 165, width: screenWidth, height: rect.height)
    
    core0.addSubview(lbl0)
    
    
    view0.addSubview(core0)
    scrollView.addSubview(view0)
    
    
    
    let view1:UIView = UIView(frame: CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight))
    view1.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    let gradient1 = CAGradientLayer()

    gradient1.frame = view.bounds
    gradient1.colors = [UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1).cgColor, UIColor(red: 209/255, green: 87/255, blue: 255/255, alpha: 1).cgColor]
    view1.layer.insertSublayer(gradient1, at: 0)
    
    _hnum = 600 + 270/3
    let core1:UIView = UIView(frame: CGRect(x: 0, y: screenHeight/2 - CGFloat(_hnum)/2, width: screenWidth, height: CGFloat(_hnum)))
    
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-276/3/2, y: 250 - 50, width: 276/3, height: 155/3)
    let svgImage1 = SVGKImage(named: "cloud2")
    svgImage1!.size = svgImageView.bounds.size
    svgImageView.image = svgImage1?.uiImage
    
    core1.addSubview(svgImageView)
    
    let lead1 = UILabel(frame: CGRect(x: 0, y: 337 - 55, width: screenWidth, height: 50))
     lead1.font = UIFont(name: "Futura-MediumItalic", size: 100/3)
     lead1.textAlignment = .center
     lead1.textColor = .white
     lead1.text = "set the stage"
     core1.addSubview(lead1)
     


    let lbl1 = UILabel(frame: CGRect(x: 0, y: 540 - 165, width: screenWidth, height: 270/3))
     lbl1.font = UIFont(name: "Helvetica", size: 65/3)
     lbl1.textAlignment = .center
     lbl1.textColor = .white
     lbl1.numberOfLines = 0
     lbl1.text = "capture an outdoor pic\nwith our camera\nor import one from your phone."
    

    rect = lbl1.sizeThatFits(CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
    lbl1.frame = CGRect(x: 0, y: 540 - 165, width: screenWidth, height: rect.height)

     core1.addSubview(lbl1)
     
    
    
    view1.addSubview(core1)
    scrollView.addSubview(view1)
    
    
    
    let view2:UIView = UIView(frame: CGRect(x: screenWidth*2, y: 0, width: screenWidth, height: screenHeight))
    view2.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    
    let gradient2 = CAGradientLayer()

    gradient2.frame = view.bounds
    gradient2.colors = [UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1).cgColor, UIColor(red: 209/255, green: 87/255, blue: 255/255, alpha: 1).cgColor]
    view2.layer.insertSublayer(gradient2, at: 0)
    
    _hnum = 600 + 270/3
    let core2:UIView = UIView(frame: CGRect(x: 0, y: screenHeight/2 - CGFloat(_hnum)/2, width: screenWidth, height: CGFloat(_hnum)))
    
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-252/3/2, y: 250 - 50, width: 252/3, height: 155/3)
    let svgImage2 = SVGKImage(named: "cloud3")
    svgImage2!.size = svgImageView.bounds.size
    svgImageView.image = svgImage2?.uiImage
    
    core2.addSubview(svgImageView)
    
    let lead2 = UILabel(frame: CGRect(x: 0, y: 337 - 55, width: screenWidth, height: 50))
     lead2.font = UIFont(name: "Futura-MediumItalic", size: 100/3)
     lead2.textAlignment = .center
     lead2.textColor = .white
     lead2.text = "remix the sky"
     core2.addSubview(lead2)
    
    
    let lbl2 = UILabel(frame: CGRect(x: 0, y: 540 - 165, width: screenWidth, height: 360/3))
      lbl2.font = UIFont(name: "Helvetica", size: 65/3)
      lbl2.textAlignment = .center
      lbl2.textColor = .white
      lbl2.numberOfLines = 0
      lbl2.text = "select an effect from our gallery, \nsearch on Giphy or use your own video.\n\nmove it, resize it and voilà!"
    
    
    rect = lbl2.sizeThatFits(CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
    lbl2.frame = CGRect(x: 0, y: 540 - 165, width: screenWidth, height: rect.height)
      core2.addSubview(lbl2)
    
    tap = UILabel(frame: CGRect(x: 0, y: screenHeight - 200, width: screenWidth, height: 40))
     tap.font = UIFont(name: "Helvetica-Bold", size: 75/3)
     tap.textAlignment = .center
     tap.textColor = .white
     tap.text = "LET'S GO!"
     view2.addSubview(tap)
    
    
    view2.addSubview(core2)
    
    scrollView.addSubview(view2)
    
    let _decBt = UIButton()
    
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _decBt.backgroundColor = .clear
    _decBt.frame = CGRect(x:screenWidth*2, y:0, width:screenWidth, height:screenHeight)
    _decBt.addTarget(self, action: #selector(self.goToCamera), for: .touchUpInside)
    scrollView.addSubview(_decBt)
    self.view.addSubview(scrollView)
    
    
    
    footerImage = UIImageView()
    footerImage.frame = CGRect(x: screenWidth/2-208/3/2, y: screenHeight-50, width: 185/3, height: 49/3)
    /*
    pt0 = UIImage(named:"page1icon")!
    pt1 = UIImage(named:"page2icon")!
    pt2 = UIImage(named:"page3icon")!
 */
     pt0 = SVGKImage(named: "dot1")!
     pt1 = SVGKImage(named: "dot2")!
     pt2 = SVGKImage(named: "dot3")!
    footerImage.image = pt0.uiImage
    
     self.view.addSubview(footerImage)
    
    startBlink()
    
  }
    func startBlink(){
        
        UIView.animate(withDuration:1.6, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
            self.tap.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration:1.6, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
                self.tap.alpha = 1
            }, completion: { _ in
                self.startBlink()
            })
        })
    }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let _logTitle = "tutorial"
    Analytics.logEvent(_logTitle, parameters: [
        AnalyticsParameterItemID: "id-\(_logTitle)",
        AnalyticsParameterItemName: _logTitle,
    AnalyticsParameterContentType: "cont"
    ])
  }
    @objc func goToCamera(sender: UIButton!){
        //self.delegate?.goToTutorial()
        self.delegate?.goToCamera()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            print("currentPage:", scrollView.currentPage)
            if(scrollView.currentPage == 0){
                footerImage.image = pt0.uiImage
            }else if(scrollView.currentPage == 1){
                footerImage.image = pt1.uiImage
                
            }else if(scrollView.currentPage == 2){
                footerImage.image = pt2.uiImage
                
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("currentPage:", scrollView.currentPage)
        if(scrollView.currentPage == 0){
                footerImage.image = pt0.uiImage
            }else if(scrollView.currentPage == 1){
                footerImage.image = pt1.uiImage
                
            }else if(scrollView.currentPage == 2){
                footerImage.image = pt2.uiImage
                
            }
    }

}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.bounds.width)) / self.bounds.width)
    }
}
