//
//  FiltersImageView.swift
//

import Foundation
import UIKit

// hack, because of a current bug in Xcode
typealias CoreImageImage = CIImage

class FiltersImageView: UIView {
    
    // MARK: - private variables

    private var didSetupConstraints = false
    private var didLayout = false
    private let bottomImageView = UIImageView()
    private let topImageView = UIImageView()
    private var filters = CircularArray<CIFilter?>(array:
        [nil,
        CIFilter(name: "CIGaussianBlur"),
        CIFilter(name: "CIPhotoEffectChrome"),
        CIFilter(name: "CIPhotoEffectFade"),
        CIFilter(name: "CIPhotoEffectInstant"),
        CIFilter(name: "CIPhotoEffectMono"),
        CIFilter(name: "CIPhotoEffectTransfer"),
        CIFilter(name: "CIPhotoEffectProcess"),
        CIFilter(name: "CIPhotoEffectTonal"),
        CIFilter(name: "CIPhotoEffectNoir")])
    private var nextOrPrevious = false
    private var lastTranslation: CGFloat = 0
    private var lastAbsoluteTranslation: CGFloat = 0
    private var lastDirectionWasRight: Bool?
    private var topMaskLayer = CAShapeLayer()
    
    // MARK: - public  variables

    var image: UIImage? {
        didSet {
            bottomImageView.image = image
            topImageView.image = image
        }
    }

    // MARK: - init and setup
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup();
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGestureRecognizer)
        
        addSubview(bottomImageView)
        addSubview(topImageView)
        setNeedsLayout()
        setNeedsUpdateConstraints()
    }
    
    override func layoutSubviews() {
        if !didLayout {
            didLayout = true
            
            clipsToBounds = true
            bottomImageView.frame = bounds
            bottomImageView.image = image
            bottomImageView.contentMode = .scaleAspectFill
            topImageView.frame = bounds
            topImageView.image = image
            topImageView.contentMode = .scaleAspectFill
            
            let topMaskPath = UIBezierPath(rect: CGRect(x: frame.width, y: 0, width: 0, height: frame.height))
            topMaskPath.close()
            topMaskLayer.path = topMaskPath.cgPath
            topMaskLayer.backgroundColor = UIColor.black.cgColor

            topImageView.layer.mask = topMaskLayer
        }
        super.layoutSubviews()
    }
    
    private func setupConstraints() {
        didSetupConstraints = true
    }
    
    // MARK: - private functions
    
    // MARK: - public functions
    
    @objc func didPan(recognizer: UIPanGestureRecognizer) {
        let vanillaTranslation = recognizer.translation(in: self).x
        let translation = vanillaTranslation >= 0 ? vanillaTranslation.truncatingRemainder(dividingBy: frame.width) : frame.width - (fabs(vanillaTranslation).truncatingRemainder(dividingBy: frame.width))
        
        switch recognizer.state {
        case .began:
            nextOrPrevious = true
            lastTranslation = vanillaTranslation > 0 ? frame.width : 0
            lastAbsoluteTranslation = vanillaTranslation
            lastDirectionWasRight = nil
        case .changed:
            let change = lastTranslation - (vanillaTranslation.truncatingRemainder(dividingBy: frame.width))
            if fabs(change) > frame.width / 2 {
                nextOrPrevious = true
            }
            if (vanillaTranslation >= 0 && lastTranslation <= 0) {
                nextOrPrevious = true
            }
            if (vanillaTranslation <= 0 && lastTranslation >= 0) {
                nextOrPrevious = true
            }

            if nextOrPrevious {
                nextOrPrevious = false
                if lastAbsoluteTranslation - vanillaTranslation < 0 {
                    if let lastDirectionWasRight = lastDirectionWasRight, !lastDirectionWasRight {
                        filters.previous()
                    }
                    
                    bottomImageView.image = image?.filteredImage(filter: filters.current())
                    topImageView.image = image?.filteredImage(filter: filters.previous())
                    
                    lastDirectionWasRight = true
                }
                if lastAbsoluteTranslation - vanillaTranslation > 0 {
                    if let lastDirectionWasRight = lastDirectionWasRight, lastDirectionWasRight {
                        filters.next()
                    }

                    topImageView.image = image?.filteredImage(filter: filters.current())
                    bottomImageView.image = image?.filteredImage(filter: filters.next())
                    
                    lastDirectionWasRight = false
                }
            }
            lastTranslation = vanillaTranslation.truncatingRemainder(dividingBy: frame.width)
            lastAbsoluteTranslation = vanillaTranslation

            let topMaskPath = UIBezierPath(rect: CGRect(
                x: 0,
                y: 0,
                width: translation,
                height: frame.height))
            topMaskPath.close()
            topMaskLayer.path = topMaskPath.cgPath
        case .ended, .cancelled:
            let visibleMaskPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            visibleMaskPath.close()
            
            let hiddenMaskPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: frame.height))
            hiddenMaskPath.close()
            
            if translation <= frame.width / 2 {
                if let lastDirectionWasRight = lastDirectionWasRight, lastDirectionWasRight {
                    filters.next()
                }
                topMaskLayer.animatePath(newPath: hiddenMaskPath.cgPath)
            } else {
                if let lastDirectionWasRight = lastDirectionWasRight, !lastDirectionWasRight {
                    filters.previous()
                }
                topMaskLayer.animatePath(newPath: visibleMaskPath.cgPath)
            }
        default:
            ()
        }
    }
    
    // MARK: - class functions
    
}

extension UIImage {
    func filteredImage(filter: CIFilter?) -> UIImage {
        guard let filter = filter else { return self }
        let context = CIContext(options: nil)
        let image = CoreImageImage(image: self)
        
        filter.setValue(image, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CoreImageImage else { return self }
        
        let extent = result.extent
        let cgImage = context.createCGImage(result, from: extent)
        
        return UIImage(cgImage: cgImage!, scale: scale, orientation: imageOrientation) ?? self;
//        return UIImage(CGImage: cgImage!, scale: scale, orientation: imageOrientation) ?? self
    }
}

extension CAShapeLayer {
    func animatePath(newPath: CGPath) {
        let fromValue = path
        
        path = newPath
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = 0.3
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = fromValue
        
        add(pathAnimation, forKey: "path")
    }
}
