//
//  GuideViewController.swift
//  
//
//  Created by shiweiwei on 16/3/1.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//  系统启动引导项,用多张图片切换的方式实现系统引导,图片名称为AboutSystem+序号的方式
//

import UIKit

class GuideViewController: UIViewController {
    
    private var pageControl: UIPageControl!;//=UIPageControl();//页码指标器
    
    private var startButton: UIButton!//=UIButton();//进入按钮
    
    private var scrollView: UIScrollView!
    
    var numOfPages:Int = 1;//引导页总数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = self.view.bounds
        
        scrollView = UIScrollView(frame: frame)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.contentOffset = CGPointZero
        // 将 scrollView 的 contentSize 设为屏幕宽度的3倍(根据实际情况改变)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height)
        
        scrollView.delegate = self
        //初始化UI PageControl
        var tempFrame=CGRectMake(frame.width/2-20, frame.height-80, 40, 40);
        
        pageControl=UIPageControl(frame: tempFrame);
        pageControl.numberOfPages=numOfPages;
        
        
        //初始化UIbutton
        tempFrame=CGRectMake(frame.width/2-100, frame.height-160, 200, 40);
        startButton=UIButton(frame: tempFrame);
        startButton.setTitle(BaseFunction.getIntenetString("BEGIN_WRITEDIARY"), forState:UIControlState.Normal)
        startButton.backgroundColor=UIColor(red: 55/255, green: 186/255, blue: 89/255, alpha: 0.8);
        startButton.addTarget(self,action: #selector(GuideViewController.buttonPressed(_:)),forControlEvents: UIControlEvents.TouchUpInside)
        
        //初始化完毕
        
        for index  in 0..<numOfPages {
            let imageView = UIImageView(image: UIImage(named: "AboutSystem\(index + 1)"))
            imageView.frame = CGRect(x: frame.size.width * CGFloat(index), y: 0, width: frame.size.width, height: frame.size.height)
            scrollView.addSubview(imageView)
        }
        
        self.view.addSubview(scrollView)
        
        self.view.addSubview(self.pageControl)
        pageControl.hidden=false;
        
        self.view.addSubview(self.startButton);
        
        startButton.hidden=false;
        
        // 给开始按钮设置圆角
        startButton.layer.cornerRadius = 15.0
        if numOfPages>1
        {
            // 隐藏开始按钮
            startButton.alpha = 0.0
        }
    }
    
    // 隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //进入主窗口
    func buttonPressed(button: UIButton) {
        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let viewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
        
        self.presentViewController(viewController, animated: true, completion:nil)
    }
}

// MARK: - UIScrollViewDelegate
extension GuideViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        
        // 因为currentPage是从0开始，所以numOfPages减1
        if pageControl.currentPage == numOfPages - 1 {
            UIView.animateWithDuration(0.5) {
                self.startButton.alpha = 1.0
            }
        } else {
            UIView.animateWithDuration(0.2) {
                self.startButton.alpha = 0.0
            }
        }
    }
}