//
//  LoopView.swift
//  WirelessLoop
//
//  Created by 王亮 on 15/11/26.
//  Copyright © 2015年 wangliang. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

private let ID="loopViewCell"

class LoopView: UIView {
    
    private lazy var tipView: UIView=UIView()
    private lazy var tipLabel: UILabel=UILabel()
   
    //url数组
    private var imageUrls: [NSURL]?
    
    //描述信息数组
    private var imageTips: [String]?
    private var timer: NSTimer?
    private var timeInterval: NSTimeInterval=3.0
    //懒加载: collectionView
    private lazy var collectionView=UICollectionView(frame: CGRectZero, collectionViewLayout: LoopViewLayout())

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 自定义CollectionViewLayout
    private class LoopViewLayout: UICollectionViewFlowLayout {
        
        private override func prepareLayout() {
            
            itemSize=collectionView!.bounds.size
            minimumInteritemSpacing=0
            minimumLineSpacing=0
            scrollDirection=UICollectionViewScrollDirection.Horizontal;
            
            collectionView?.pagingEnabled=true
            collectionView?.bounces=false
            
            super.prepareLayout()
        }
    }
    
    //MARK: 公共函数 -- 显示图像
    func showImages(urls: [NSURL],tips: [String]?,timeInterval: NSTimeInterval=3.0, selectedImage:(index: Int) ->()) {
        
        self.timeInterval=timeInterval
        
        //准备数据
        prepareData(urls, tips: tips)
        
        if imageUrls?.count <= 1 {
            
            return
        }
        
        //一开始就滚动到倒数第二张图片 urls.count(未加载[0]、[1]的总数)
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: urls.count, inSection: 0),
                atScrollPosition: .Left,
                animated: false)
        }
        
        //开启时钟
        startTimer()
     }
    
    private func prepareData(urls: [NSURL],tips: [String]?) {
        
        //断言
        assert(tips == nil || tips?.count == urls.count,"报错: tips为空 或 总数与urls不相等")
        
        //记录数据
        imageUrls=urls
        imageTips=tips
        
        //处理URL数组
        if imageUrls?.count > 1 {
           
            //TODO: 分析为啥只添加两个元素
            imageUrls?.append(imageUrls![0])
            imageUrls?.append(imageUrls![1])
        }
        
        if imageTips?.count > 1 {
            
            imageTips?.append(imageTips![0])
            imageTips?.append(imageTips![1])
        }
        
    }
    
    //旋转时重新调整视图布局
    func resetViewLayout() {
        
        let indexPath=collectionView.indexPathsForVisibleItems()[0]
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.stopTimer()
            
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
            
            self.startTimer()
        }
    }
    
    //开启时钟
    func startTimer() {
        
        if imageUrls?.count <= 1 || timer != nil {
            
            return
        }
        
        timer=NSTimer(timeInterval: timeInterval, target: self, selector: "timerDidStart", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func timerDidStart() {
        
        guard let indexPath=collectionView.indexPathsForVisibleItems().last else {
            
            return
        }
        
        let nextStep=NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
       
        if nextStep.item == imageUrls?.count {
            
            return
        }
        
        collectionView.scrollToItemAtIndexPath(nextStep, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    //停止时钟
    func stopTimer() {
        
        timer?.invalidate()
        timer=nil
    }
}

//设置界面
private extension LoopView {
    
   private func prepareUI() {
    
        prepareCollectionView()
        prepareTipView()
    }
    
    private func prepareCollectionView() {
        
        addSubview(collectionView)
    
        collectionView.backgroundColor=UIColor.whiteColor()
        
        collectionView.registerClass(LoopViewCell.self,forCellWithReuseIdentifier: ID)
        
        collectionView.dataSource=self
        collectionView.delegate=self
        
        
        //布局collectionView
        collectionView.snp_makeConstraints { (make) -> Void in
            
            make.left.bottom.right.top.equalTo(self)
        }
    }
    
    private func prepareTipView() {
        
        
    }
}

//MARK-- collectionView数据源代理
extension LoopView: UICollectionViewDataSource,UICollectionViewDelegate {
    
    //UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return imageUrls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell=collectionView.dequeueReusableCellWithReuseIdentifier(ID, forIndexPath: indexPath) as! LoopViewCell
        
        cell.imageURL=imageUrls![indexPath.row]
            
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
           
    guard var displayCellIndex=collectionView.indexPathsForVisibleItems().last?.item else {
        
            return
        }
        
        guard let imageUrls=imageUrls else {
            
            return
        }
        
        let count=imageUrls.count
        
        if displayCellIndex == count-1 || displayCellIndex == 0
        {
            displayCellIndex=(displayCellIndex == 0) ? count-2 : 1
            
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: displayCellIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        }
    }
    
    //scrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        //开始拖拽 停止时钟
        stopTimer()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //结束拖拽 开启时钟
        startTimer()
    }
  
    //测试
    
    
}

//自定义--LoopViewCell
private class LoopViewCell: UICollectionViewCell {
    
    //MARK:懒加载imageView
    private lazy var imageView: UIImageView=UIImageView()
    
    var imageURL: NSURL? {
        
        didSet{
            
            guard let imageUrl=imageURL else {
                
                print("url不存在")
                return
            }
            
            imageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, options: [SDWebImageOptions.RefreshCached,SDWebImageOptions.RetryFailed])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        //布局imageView
        imageView.snp_makeConstraints { (make) -> Void in
            
            make.left.bottom.right.top.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

