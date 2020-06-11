import UIKit
import SVGKit


protocol TutorialViewDelegate:class {
    
    func goToCamera()
}



class TutorialViewController: UIViewController, UIScrollViewDelegate {

    var pt0:UIImage!
    var pt1:UIImage!
    var pt2:UIImage!
    var footerImage: UIImageView!
    weak var  delegate:TutorialViewDelegate? = nil
    var scrollView:UIScrollView!
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    
    let _offSet:Float = 150
    
    scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    scrollView.contentSize = CGSize(width: screenWidth*3, height: screenHeight)
    
    scrollView.isPagingEnabled = true
    
    
    let view0:UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    view0.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    
    
    let label = UILabel(frame: CGRect(x: 0, y: 250 - 150, width: screenWidth, height: 114/3))
    label.font = UIFont(name: "Helvetica", size: 95/3)
    label.textAlignment = .center
    label.textColor = .white
    label.text = "welcome to"
    view0.addSubview(label)
    
    var svgImageView: UIImageView
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-930/3/2, y: 325 - 150, width: 930/3, height: 460/3)
    let svgImage0 = SVGKImage(named: "magicsky_top")
    svgImage0!.size = svgImageView.bounds.size
    svgImageView.image = svgImage0?.uiImage
    
    view0.addSubview(svgImageView)
    
    let lbl0 = UILabel(frame: CGRect(x: 0, y: 515 - 150, width: screenWidth, height: 180/3))
    lbl0.font = UIFont(name: "Helvetica", size: 75/3)
    lbl0.textAlignment = .center
    lbl0.textColor = .white
    lbl0.numberOfLines = 0
    lbl0.text = "turn the sky into a\nplayground for creativity"
    view0.addSubview(lbl0)
    
    
    scrollView.addSubview(view0)
    
    
    
    let view1:UIView = UIView(frame: CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight))
    view1.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-276/3/2, y: 250 - 150, width: 276/3, height: 155/3)
    let svgImage1 = SVGKImage(named: "cloud2")
    svgImage1!.size = svgImageView.bounds.size
    svgImageView.image = svgImage1?.uiImage
    
    view1.addSubview(svgImageView)
    
    let lead1 = UILabel(frame: CGRect(x: 0, y: 335 - 150, width: screenWidth, height: 40))
     lead1.font = UIFont(name: "Helvetica-Bold", size: 75/3)
     lead1.textAlignment = .center
     lead1.textColor = .white
     lead1.text = "set the stage!"
     view1.addSubview(lead1)
     


    let lbl1 = UILabel(frame: CGRect(x: 0, y: 400 - 150, width: screenWidth, height: 270/3))
     lbl1.font = UIFont(name: "Helvetica", size: 75/3)
     lbl1.textAlignment = .center
     lbl1.textColor = .white
     lbl1.numberOfLines = 0
     lbl1.text = "capture an outdoor pic\nwith our camera or import\none of your own"
     view1.addSubview(lbl1)
     
    
    
    scrollView.addSubview(view1)
    
    
    
    let view2:UIView = UIView(frame: CGRect(x: screenWidth*2, y: 0, width: screenWidth, height: screenHeight))
    view2.backgroundColor = UIColor(red: 0/255, green: 53/255, blue: 255/255, alpha: 1)
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: screenWidth/2-252/3/2, y: 250 - 150, width: 252/3, height: 155/3)
    let svgImage2 = SVGKImage(named: "cloud3")
    svgImage2!.size = svgImageView.bounds.size
    svgImageView.image = svgImage2?.uiImage
    
    view2.addSubview(svgImageView)
    
    let lead2 = UILabel(frame: CGRect(x: 0, y: 335 - 150, width: screenWidth, height: 40))
     lead2.font = UIFont(name: "Helvetica-Bold", size: 75/3)
     lead2.textAlignment = .center
     lead2.textColor = .white
     lead2.text = "remix the sky"
     view2.addSubview(lead2)
    
    
    let lbl2 = UILabel(frame: CGRect(x: 0, y: 400 - 150, width: screenWidth, height: 270/3))
      lbl2.font = UIFont(name: "Helvetica", size: 75/3)
      lbl2.textAlignment = .center
      lbl2.textColor = .white
      lbl2.numberOfLines = 0
      lbl2.text = "select a visual from our\ncurated gallery, search for\na gif or import your own "
      view2.addSubview(lbl2)
    
    let tap = UILabel(frame: CGRect(x: 0, y: 635 - 150, width: screenWidth, height: 40))
     tap.font = UIFont(name: "Helvetica-Bold", size: 100/3)
     tap.textAlignment = .center
     tap.textColor = .white
     tap.text = "TAP TO CREATE"
     view2.addSubview(tap)
    
    
    
    scrollView.addSubview(view2)
    
    let _decBt = UIButton()
    
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _decBt.backgroundColor = .clear
    _decBt.frame = CGRect(x:screenWidth*2, y:0, width:screenWidth, height:screenHeight)
    _decBt.addTarget(self, action: #selector(self.goToCamera), for: .touchUpInside)
    scrollView.addSubview(_decBt)
    self.view.addSubview(scrollView)
    
    
    
    footerImage = UIImageView()
    footerImage.frame = CGRect(x: screenWidth/2-208/3/2, y: screenHeight-50, width: 208/3, height: 52/3)
    pt0 = UIImage(named:"page1icon")!
    pt1 = UIImage(named:"page2icon")!
    pt2 = UIImage(named:"page3icon")!
    footerImage.image = pt0
    
     self.view.addSubview(footerImage)
    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    @objc func goToCamera(sender: UIButton!){
        //self.delegate?.goToTutorial()
        self.delegate?.goToCamera()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            print("currentPage:", scrollView.currentPage)
            if(scrollView.currentPage == 0){
                footerImage.image = pt0
            }else if(scrollView.currentPage == 1){
                footerImage.image = pt1
                
            }else if(scrollView.currentPage == 2){
                footerImage.image = pt2
                
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("currentPage:", scrollView.currentPage)
        if(scrollView.currentPage == 0){
                footerImage.image = pt0
            }else if(scrollView.currentPage == 1){
                footerImage.image = pt1
                
            }else if(scrollView.currentPage == 2){
                footerImage.image = pt2
                
            }
    }

}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.bounds.width)) / self.bounds.width)
    }
}
