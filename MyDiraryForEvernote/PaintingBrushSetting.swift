//
//  PaintingBrushSetting.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/1/31.
//  Copyright © 2016年 zhangao. All rights reserved.
//

import UIKit

class PaintingBrushSetting: UIViewController {
    
    @IBOutlet weak var slidePencilSense: UISlider!
    
    @IBAction func doPencilSenseChanged(sender: UISlider) {
        mainViewController?.board.pencilSense=CGFloat(sender.value);
        mainViewController?.saveSystemPara();
    }
    @IBOutlet weak var segmentColor: UISegmentedControl!
    @IBOutlet weak var segmentWidth: UISegmentedControl!
    
    var mainViewController:ViewController?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //color图标
        segmentColor.setImage(UIImage(named:"black")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 0);
        segmentColor.setImage(UIImage(named:"blue")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 1);
        segmentColor.setImage(UIImage(named:"red")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 2);
        segmentColor.setImage(UIImage(named:"yellow")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 3);
        segmentColor.setImage(UIImage(named:"green")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 4);
        //width图标
        segmentWidth.setImage(UIImage(named:"stroke1")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 0);
        segmentWidth.setImage(UIImage(named:"stroke2")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 1);
        segmentWidth.setImage(UIImage(named:"stroke3")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 2);
        segmentWidth.setImage(UIImage(named:"stroke4")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 3);
        segmentWidth.setImage(UIImage(named:"stroke5")!.imageWithRenderingMode(.AlwaysOriginal), forSegmentAtIndex: 4);
        
        
        
        let widthIndex=Int((mainViewController?.board.strokeWidth)!);
        segmentWidth.selectedSegmentIndex=widthIndex-1;
        
        let brushColor=mainViewController?.board.strokeColor;
        
        if brushColor==UIColor.blackColor()
        {
            self.segmentColor.selectedSegmentIndex=0;
        };
        
        if brushColor==UIColor.blueColor()
        {
            self.segmentColor.selectedSegmentIndex=1;
        };
        
        if brushColor==UIColor.redColor()
        {
            self.segmentColor.selectedSegmentIndex=2;
        };
        if brushColor==UIColor.yellowColor()
        {
            self.segmentColor.selectedSegmentIndex=3;
        };
        if brushColor==UIColor.greenColor()
        {
            self.segmentColor.selectedSegmentIndex=4;
        };
        
        slidePencilSense.value=Float((mainViewController?.board.pencilSense)!);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func setBrushWidth(sender: UISegmentedControl) {
        
        mainViewController?.board.strokeWidth=CGFloat(sender.selectedSegmentIndex+1);
        //系统参数保存一下
        mainViewController?.saveSystemPara();
        
    }
    
    
    @IBAction func setBrushColor(sender: UISegmentedControl) {
        let color=[UIColor.blackColor(),UIColor.blueColor(),UIColor.redColor(),UIColor.yellowColor(),UIColor.greenColor()];
        mainViewController?.board.strokeColor=color[sender.selectedSegmentIndex];
        //系统参数保存一下
        mainViewController?.saveSystemPara();
    }
    @IBAction func doCloseWnd(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}
