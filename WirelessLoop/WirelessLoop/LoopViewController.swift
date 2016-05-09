//
//  LoopViewController.swift
//  WirelessLoop
//
//  Created by 王亮 on 15/11/26.
//  Copyright © 2015年 wangliang. All rights reserved.
//

import UIKit
import SnapKit

class LoopViewController: UIViewController {
    
    //MARK: 懒加载loopView
    private lazy var loopView: LoopView=LoopView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor=UIColor.whiteColor()
        //此属性很关键
        self.automaticallyAdjustsScrollViewInsets=false
   
        setupLoopView()
    }
    
    private func setupLoopView() {
        
        view.addSubview(loopView)
     
        //布局loopView
        loopView.snp_makeConstraints { (make) -> Void in
            
            make.top.equalTo(view.snp_top).offset(64);
            make.left.right.equalTo(view)
            make.height.equalTo(180)
        }
        
        //数据数组
        var urls=[NSURL]()
        var tips=[String]()
        
        //此处只是加载对应图片URL或imageName
        for i in 1...5 {
            
            let imageName=String(format: "%02d.png", i)
            
            urls.append(NSBundle.mainBundle().URLForResource(imageName, withExtension: nil)!)
            
            tips.append("自然风景 -- \(i)")
        }
        
        loopView.showImages(urls, tips: tips) { (index) -> () in
            
            print("选中了第\(index)张图片")
        }
        
    }
    
    //TODO:分析此方法
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        loopView.resetViewLayout()
    }

}
