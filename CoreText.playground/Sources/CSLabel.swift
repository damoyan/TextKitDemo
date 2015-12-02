import UIKit

public class CSLabel: UIView {
    
}

extension NSMutableAttributedString {
    public func insert(attachment attachment: NSTextAttachment, atIndex index: Int) {
        // TODO: - add CTRunDelegate for the attachment
    }
}


var frame: CTFrame?
var lines: [CTLine]?
var runs: [CTRun]?

public func createFrame(attriString: NSAttributedString, boundingWith width: CGFloat) {
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    let path = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: width, height: CGFloat.max), nil)
    frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
}