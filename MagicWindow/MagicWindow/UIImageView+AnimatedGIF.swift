import Foundation
import UIKit
import ImageIO

extension UIImageView {

    func animateGIF(data: Data,
                    animationRepeatCount: UInt = 500,
                    completion: (() -> Void)? = nil) {
        guard let animatedGIFImage = UIImage.animatedGIF(data: data) else {
            return
        }

        self.image = animatedGIFImage.images?.last
        self.animationImages = animatedGIFImage.images
        self.animationDuration = animatedGIFImage.duration
        self.animationRepeatCount = Int(animationRepeatCount)
        //self.startAnimating()

        print(self.animationDuration)
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animatedGIFImage.duration * Double(animationRepeatCount)) {
            completion?()
            
            
        }
    }
    func replaceImg(images: [UIImage],
                    duration:float_t,
    animationRepeatCount: UInt = 500,
    completion: (() -> Void)? = nil) {

        self.image = images.last
           self.animationImages = images
        self.animationDuration = TimeInterval(duration)
           self.animationRepeatCount = Int(animationRepeatCount)
           //self.startAnimating()

           print(self.animationDuration)
           
           
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 13 * Double(animationRepeatCount)) {
               completion?()
               
               
           }
       }
}
