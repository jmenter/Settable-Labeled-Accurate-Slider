/*
 
 Copyright (c) 2018 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import UIKit

class LabeledSlider: AccurateSlider {

    @IBInspectable var annotationText:String? {
        get { return annotationLabel.text }
        set { annotationLabel.text = newValue }
    }
    
    let numberFormatter = NumberFormatter()
    
    fileprivate let label = UILabel()
    fileprivate let annotationLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNextCondensed-Medium", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        addSubview(label)
        
        annotationLabel.frame = CGRect(x: 2, y: 0, width: frame.size.width - 4, height: 11)
        annotationLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: 9)
        annotationLabel.textColor = .gray
        annotationLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(annotationLabel)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(controlWasTapped(gestureRecognizer:)))
        tapGR.numberOfTapsRequired = 2
        addGestureRecognizer(tapGR)
    }
    
    @objc
    fileprivate func controlWasTapped(gestureRecognizer: UITapGestureRecognizer) {
        var valueTextField:UITextField?
        let alertController = UIAlertController(title: annotationText ?? "Edit Value", message: "Enter a new value between\n\(minimumValue) and \(maximumValue)", preferredStyle: .alert)
        alertController.addTextField { textField in
            valueTextField = textField
            textField.keyboardType = .decimalPad
            textField.text = self.value.description
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.setValue(Float(valueTextField?.text ?? "") ?? 0, animated: true)
            self.sendActions(for: .valueChanged)
        }))
        parentViewController?.present(alertController, animated: true) {
            guard let valueTextField = valueTextField else { return }
            valueTextField.selectedTextRange = valueTextField.textRange(from: valueTextField.beginningOfDocument,
                                                                        to: valueTextField.endOfDocument)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubview(toFront: label)
        bringSubview(toFront: annotationLabel)
        label.frame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds),
                                value: value).insetBy(dx: 4, dy: 0)
        label.text = numberFormatter.string(from: NSNumber.init(value: value))
        label.textColor = .darkGray
    }
    
    fileprivate var parentViewController: UIViewController? {
        get {
            var possibleResponder:UIResponder? = self
            while possibleResponder != nil, !possibleResponder!.isKind(of: UIViewController.self) {
                possibleResponder = possibleResponder?.next
            }
            return possibleResponder as? UIViewController ?? nil
        }
    }
    
}
