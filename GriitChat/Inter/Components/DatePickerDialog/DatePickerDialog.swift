//
//  DatePickerDialog.swift
//  GriitChat
//
//  Created by leo on 28/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol DatePickerDialogDelegate {
    func onSelectDate(date: String);
}

class DatePickerDialog: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnSelect: UIButton!
    
    var delegate: DatePickerDialogDelegate? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("DatePickerDialog", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    func showDialog(isShow: Bool) {
        self.isHidden = false;
        self.alpha = isShow ? 0 : 1;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = isShow ? 1 : 0;
        }) { (result: Bool) in
            self.isHidden = !isShow;
            self.alpha = 1;
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        showDialog(isShow: false);
    }
    
    @IBAction func onSelect(_ sender: Any) {
//        datePicker.date
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        /*
        if let date = dateFormatterGet.date(from: "2016-02-29 12:24:26"){
            print(dateFormatterPrint.string(from: date))
        }
        else {
            print("There was an error decoding the string")
        }*/
        
        let strDate: String = "1234-12-12";
        delegate?.onSelectDate(date: strDate);
        showDialog(isShow: false);
    }
    
}
