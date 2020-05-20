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
}
