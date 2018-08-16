//
//  ScrollPager.swift
//  PagerTest
//
//  Created by GoldHorse on 7/21/18.
//  Copyright © 2018 GoldHorse. All rights reserved.
//

import UIKit

@objc protocol ScrollPagerDelegate {
    func onChangeCurrentPage(index: Int);
    
    /**
     
     //  +   <<==    Current     ==>>   -
    position : -1 ~ 1
    */
    func onScroll(currentPage: Int, offset: CGFloat);
    
    //scrDirection :    0: left
    //                  1: right
    @objc optional func onScroll(scrDirection: Int);
    
    @objc optional func enableActions(state: Bool);
}

enum ScrollScrDir: Int {
    case Left = 0;
    case Right = 1;
}

class ScrollPager: UIScrollView, UIScrollViewDelegate {
    
    enum Position {
        case Prev;
        case Next;
    };
    enum ScrollPos {
        case AddedPage;
        case OrgPage;
    }
    
    var selectedIndex = 0;
    var pageDelegate: ScrollPagerDelegate? = nil;
    
    var isScrollingByCode = false;
    var isScrollingByAID = false;       //Scrolling by Add / Insert / Delete
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        self.delegate = self;
    }
    
    override func layoutSubviews() {
        isPagingEnabled = true
        showsVerticalScrollIndicator = false;
        showsHorizontalScrollIndicator = false;
        bounces = false;
        
        resizeViews();
    }
    func addPage(page: ViewPage) -> Int {
        return insertPage(page: page, index: subviews.count);
    }
    
    func insertPage(page: ViewPage, index: Int) -> Int {
        var pageIndex = index;
        let count = subviews.count;
        if (pageIndex > count) {
            pageIndex = count;
        }
        page.initState();
        insertSubview(page, at: pageIndex);
        resizeViews();
        
        if (getPageCount() == 1) {
            scrollToIndex(index: 0);
        }
        return pageIndex;
    }
    
    func insertPage(page: ViewPage, position: Position, scrollTo: ScrollPos) {
        insertPage(page: page, position: position, scrollTo: scrollTo, duration: nil, completion: nil);
    }
    
    func insertPage(page: ViewPage, position: Position, scrollTo: ScrollPos, duration: Double?, completion: (() -> Void)?) {
        var newPos = 0;
        var orgPage = getPageIndex();
        
        if (position == .Prev) {
            newPos = insertPage(page: page, index: getPageIndex());
            orgPage += 1;
        } else {
            newPos = insertPage(page: page, index: getPageIndex() + 1);
        }
        if (scrollTo == .AddedPage) {
            scrollToIndex(index: newPos, duration: duration!) {
                completion?();
            }
        } else {
            scrollToIndex(index: orgPage);
        }
    }
    
    func removeAllPages() {
        let count = getPageCount();
        
        for _ in 0 ..< count {
            subviews [0].removeFromSuperview();
        }
        scrollToIndex(index: 0);
    }
    
    func removePage(index: Int) -> ViewPage? {
        if (index >= getPageCount()) {
            return nil;
        }
        let rtnView = subviews [index];
        subviews [index].removeFromSuperview();
        
        isScrollingByCode = true;
        
        resizeViews();
        scrollToIndex(index: getPageIndex());
        
        isScrollingByCode = false;
        return rtnView as? ViewPage;
    }
    
    func getPageCount() -> Int {
        return subviews.count;
    }
    
    func getPageIndex() -> Int {
        return Int(contentOffset.x / frame.width);
    }
    
    func scrollToIndex(index: Int) {
        scrollToIndex(index: index, duration: 0.0, completion: nil);
    }
    
    func scrollToIndex(index: Int, duration: Double, completion: (() -> Void)?) {
        var newOffset: CGFloat = 0.0;
        if (index >= getPageCount()) {
            newOffset = frame.width * CGFloat(max(0, getPageCount() - 1));
        } else {
            newOffset = frame.width * CGFloat(index);
        }
        
        isScrollingByCode = true;
        pageDelegate?.enableActions?(state: false);
        
        if (!self.isScrollingByAID) {
            getCurPage()?.onDeactive();
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.contentOffset.x = newOffset;
        }) { (result: Bool) in
            self.selectedIndex = index;
            self.pageDelegate?.enableActions?(state: true);
            
            if (!self.isScrollingByAID) {
                self.getCurPage()?.onActive();
            }
            self.isScrollingByCode = false;
            completion?();
        }
    }
    
    func scrollTo(_ type: ScrollScrDir) {
        if (type == .Left) {
            scrollToIndex(index: selectedIndex - 1);
        } else {
            scrollToIndex(index: selectedIndex + 1);
        }
    }
    
    func removeExceptOnlyCurPage() {
        let curIndex = getPageIndex();
        let count = getPageCount();
        
        isScrollingByAID = true;
        if (curIndex + 1 < count) {
            for _ in curIndex + 1 ..< count {
                _ = removePage(index: curIndex + 1);
            }
        }
        
        for _ in 0 ..< curIndex {
            _ = removePage(index: 0);
        }
        
        isScrollingByAID = false;
        selectedIndex = 0;
    }

    func resizeViews() {
        isScrollingByCode = true;
        
        let count = subviews.count;
        contentSize = CGSize(width: frame.width * CGFloat(count), height: frame.height);

        for i in 0 ..< count {
            subviews [i].frame = CGRect(x: frame.width * CGFloat(i), y: 0, width: frame.width, height: frame.height)
        }
        
        isScrollingByCode = false;
    }
    
    func isPageExist(pageName: String) -> Bool {
        let count = getPageCount();
        for i in 0 ..< count {
            let page = subviews [i] as! ViewPage;
            if (pageName == page.pageName) {
                return true;
            }
        }
        return false;
    }
    
    func getCurPage() -> ViewPage? {
        return getPageWithIndex( index: getPageIndex());
    }
    
    //-1 : failed (not found).
    func getPageIndex(pageName: String) -> Int {
        let count = getPageCount();
        for i in 0 ..< count {
            let page = subviews [i] as! ViewPage;
            if (pageName == page.pageName) {
                return i;
            }
        }
        return -1;
    }
    
    func getPageWithIndex(index: Int) -> ViewPage? {
        if (index >= getPageCount()) { return nil; }
        return subviews [index] as? ViewPage;
    }
    
    func printPageNames() {
        let count = getPageCount();
        debugPrint("........ Page Names ........");
        
        for i in 0 ..< count {
            let page = subviews [i] as! ViewPage;
            
            debugPrint(i + 1, " : ", page.pageName);
        }
    }
    
    //  +   <<==    Current     ==>>   -
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        
        let remainder = page.truncatingRemainder(dividingBy: 1);
        
        if (remainder == 0 && selectedIndex != Int(page)) {
            //Scroll Page Changed
            let direction = Int(page) < selectedIndex ? ScrollScrDir.Left : ScrollScrDir.Right;
            
            if (!isScrollingByAID) {
                getPageWithIndex(index: selectedIndex)?.onDeactive();
            }
            
            selectedIndex = Int(page);
            //onChangeCurrentPage()
            if (!isScrollingByCode) {
                pageDelegate?.onChangeCurrentPage(index: selectedIndex);
                pageDelegate?.onScroll?(scrDirection: direction.rawValue);
            }
            if (!isScrollingByAID) {
                getPageWithIndex(index: selectedIndex)?.onActive();
            }
        } else {
            let offset = (frame.width * CGFloat(selectedIndex) - contentOffset.x) / frame.width;
            //onScroll
            pageDelegate?.onScroll(currentPage: selectedIndex, offset: offset);
        }
    }
}
