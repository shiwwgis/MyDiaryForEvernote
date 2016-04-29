//
//  ViewController.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-15.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit
import CoreBluetooth

//MARK:- 在Controller里扩展一个消息提示框
extension UIViewController//实现一个提示框
{
    func ShowNotice(caption:String,_ message:String)//显示一个可以自动消失的消息提示框,by shiww//必须用支持国际化的字符串
    {
        let intelCaption=BaseFunction.getIntenetString(caption);
        let intelMessage=BaseFunction.getIntenetString(message);
        
        let alertController = UIAlertController(title: intelCaption,
            message: intelMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alertController, animated: true)
            {
                NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:#selector(UIViewController.removeIt(_:)), userInfo:alertController, repeats:false);
        }
    }
    
    func removeIt(sender:NSTimer)    {
        let alertVC=sender.userInfo as! UIAlertController;
        
        //设置动画效果，动画时间长度 1 秒。
        UIView.animateWithDuration(1, animations:
            {()-> Void in
                alertVC.view.alpha = 0.0
            },
            completion:{
                (finished:Bool) -> Void in
                alertVC.dismissViewControllerAnimated(true,completion:nil);
        })
    }
    
    
}
//MARK:- NSUserDefaults中扩展UIColor存储

//必须做一个扩展,否则UIColor存不进去
extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
    
}
//MARK:- ViewController定义

class ViewController: UIViewController,UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var btnInsertImg: UIButton!//插入图片
    
    @IBOutlet weak var btnStamp: UIButton!//自动加上日记头
    
    var city:String="beijing";
    
    @IBOutlet weak var toolboxView: UIView!
    var brushes = [PencilBrush(), LineBrush(), DashLineBrush(), RectangleBrush(), EllipseBrush(), HightlightBrush(),EraserBrush(),TextBrush(),ImageBrush()];
    //added by shiww,让系统支持多页
    var pages=Pages();
    
    @IBAction func doUploadToEvernote(sender: UIButton) {
        //首先连接Evernote
        let consumerKey="chinagis001";
        let consumerscret="c30343eba6ba509f";
        let evernotehost="app.yinxiang.com";
        
        ENSession.setSharedSessionConsumerKey(consumerKey, consumerSecret: consumerscret, optionalHost: evernotehost);
        
        if ENSession.sharedSession() == nil
        {
            self.ShowNotice("SORRY","EVERNOTE_LOGIN_FAILED");
            
            return;
        }
        
        
        
        ENSession.sharedSession().authenticateWithViewController(self, preferRegistration: true)
            { (myerror:NSError!) -> Void in
                if ((myerror) != nil)
                {
                    self.ShowNotice("SORRY","EVERNOTE_LOGIN_FAILED");
                    
                }
                else
                {
                    if !ENSession.sharedSession().isAuthenticated
                    {
                        self.ShowNotice("SORRY","EVERNOTE_LOGIN_FAILED");
                        
                        return;
                    }
                    else
                    {
                        let popVC=UploadToEvernoteController();
                        
                        popVC.mainViewController=self;
                        
                        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
                        popVC.popoverPresentationController!.delegate = self
                        let popOverController = popVC.popoverPresentationController
                        popOverController!.sourceView = sender;
                        popOverController!.sourceRect = sender.bounds
                        popVC.preferredContentSize=CGSizeMake(303,380);
                        popOverController?.permittedArrowDirections = .Any
                        self.presentViewController(popVC, animated: true, completion: nil)
                        
                        
                        
                    }
                    
                }
        }
        
        
        
    }
    //切换笔刷
    func doPenSwitch(sender: UIButton) {
        if sender.selected && sender.tag != 8
        {
            return;
        }//added by shiww,如果是同一个按钮,直接返回.
        //如果点了不同的按钮,则切换笔刷
        
        let btnList=[btnPencil,btnPenLine,btnPenDashLine,btnPenBox,btnPenCircle,btnPenHLight,btnPenEraser,btnStamp,btnInsertImg];
        for btnTemp in btnList
        {
            if btnTemp.tag != sender.tag
            {
                btnTemp.selected=false;
            }
            else
            {
                btnTemp.selected=true;
                if btnTemp.tag==5//added by shiww,如果是高亮笔刷,颜色设置为黄色
                {
                    self.saveSystemPara();
                    self.board.strokeColor=UIColor.yellowColor();
                }
                else
                {
                    let defaults = NSUserDefaults.standardUserDefaults();
                    if  (defaults.objectForKey("strokeWidth") != nil)
                    {
                        self.board.strokeWidth = defaults.objectForKey("strokeWidth") as! CGFloat;
                    }
                    if  (defaults.objectForKey("strokeColor") != nil)
                    {
                        self.board.strokeColor = defaults.colorForKey("strokeColor")!
                    }
                    
                }
            }
        }
        self.board.brush = self.brushes[sender.tag];
        //added by shiww
        if sender.tag==7 && sender.selected//是插入日记title
        {
            if self.board.brush is TextBrush
            {
                let textBrush=self.board.brush as! TextBrush
                
                textBrush.text=BaseFunction.getDiaryTitle(self.city);
                
                textBrush.textColor=self.board.strokeColor;
            }
        }
        
        //added by shiww
        if sender.tag==8 && sender.selected//是插入图片
        {
            let pickerController = UIImagePickerController();
            pickerController.delegate = self;
            self.presentViewController(pickerController, animated: true, completion: nil);
        }
        
    }
    
    // MARK: UIImagePickerControllerDelegate Methods,插入图片时把图片传给笔刷
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.board.brush is ImageBrush
        {
            let imgBrush=self.board.brush as! ImageBrush
            
            let imagePic = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            imgBrush.image=imagePic;
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBOutlet weak var btnPenEraser: UIButton!
    @IBOutlet weak var btnPenHLight: UIButton!
    @IBOutlet weak var btnPenCircle: UIButton!
    @IBOutlet weak var btnPenBox: UIButton!
    @IBOutlet weak var btnPenDashLine: UIButton!
    @IBOutlet weak var btnPenLine: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    
    //added by shiww,保存页面到本地文件中,图片格式
    
    @IBAction func saveCurrentPages(sender: UIButton) {
        if self.pages.savePageMetainfo()
        {
            self.pages.savePage(self.board.takeImage(false));
            self.pages.savePage(self.board.takeImage(true),forEvernote:true);
            
        }
        
    }
    
    private func loadImagefromFile(filename:String)
    {
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        let pagefilePath=docDir+"/"+filename+".png";
        
        if let tempImage=UIImage(contentsOfFile: pagefilePath)
        {
            self.board.loadImage(tempImage);
        }
        
    }
    
    private func saveImageToFile(filename:String)->Bool
    {
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        let pagefilePath=docDir+"/"+filename+".png";
        
        //        print(pagefilePath);
        
        let saveResult=UIImagePNGRepresentation(self.board.takeImage(false))!.writeToFile(pagefilePath, atomically: true);
        
        if saveResult
        {
            //            print("write pagedata to \(pagefilePath) succeed!");
        }
        return saveResult;
    }
    
    @IBOutlet var board: Board!
    
    @IBOutlet var topView: UIView!
    
    
    @IBAction func doSetBkground(sender: UIButton) {
        //added by shiww,设置背景信纸
        let popVC=SetBkgroundViewCtrller();
        popVC.mainViewController=self;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        popVC.popoverPresentationController!.delegate = self
        let popOverController = popVC.popoverPresentationController
        popOverController!.sourceView = sender;
        popOverController!.sourceRect = sender.bounds
        popVC.preferredContentSize=CGSizeMake(535,628);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cbCentralMgr=CBCentralManager();
        let exDevices=cbCentralMgr.retrieveConnectedPeripheralsWithServices([CBUUID(string: "180A")]);
        
        //            print(exDevices.count);
        
        
        for exDevice in exDevices
        {
            if exDevice.name=="Apple Pencil"
            {
                self.board.hasPencil=true;
            }
            
        }

        //处理一下视图大小
        //1.让board充满大小
        let viewBounds=self.view.bounds;
        var viewFrame=CGRectMake(0,0,viewBounds.width,viewBounds.height);
        self.board.frame=viewFrame;
        //2.让工具条充满
        viewFrame=CGRectMake(0,0,viewBounds.width,self.topView.bounds.height);
        self.topView.frame=viewFrame;
        
        let scale=viewBounds.width/1024;
        var index:CGFloat=0;
        let margin=(viewBounds.width-CGFloat(topView.subviews.count)*(topView.subviews[0].bounds.width*scale+2))/2;
        
        for subview in topView.subviews
        {
            subview.bounds=CGRect(x: 0.0,y: 0.0,width:subview.bounds.width*scale,height:subview.bounds.height*scale);
            subview.frame=CGRect(x: margin+index*(subview.bounds.width+2),y: subview.frame.origin.y,width: subview.bounds.width,height: subview.bounds.height)
            index++;
           // print(subview.accessibilityLabel);
        }
//        self.topView.autoresizingMask=[UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin,UIViewAutoresizing.FlexibleRightMargin,UIViewAutoresizing.FlexibleWidth];
//        
//        self.topView.autoresizesSubviews=true;
        //处理完毕
        
        
        self.board.brush = brushes[0]
        
        self.loadSystemPara();
        
        //added by shiww,设置默认背景
//        self.board.backgroundColor = UIColor(patternImage: UIImage(named: self.board.bkImgName)!);
        self.setBackgroundColor(UIImage(named: self.board.bkImgName)!)
        
        
        //added by shiww,设置按钮图片和按钮事件
        let btnList=[btnPencil,btnPenLine,btnPenDashLine,btnPenBox,btnPenCircle,btnPenHLight,btnPenEraser];
        for btnTemp in btnList
        {
            btnTemp.imageView?.contentMode=UIViewContentMode.ScaleToFill;
            btnTemp.addTarget(self,action:#selector(ViewController.doPenSwitch(_:)),forControlEvents:.TouchUpInside);//点击事件
            
            //添加长按事件
            let longPress=UILongPressGestureRecognizer(target: self, action: #selector(ViewController.doSetBrush(_:)));
            longPress.minimumPressDuration=0.4;
            btnTemp.addGestureRecognizer(longPress);
            
        }
        
        btnPencil.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal);
        btnPencil.setImage(UIImage(named: "pencilck"), forState: UIControlState.Selected);
        btnPencil.selected=true;
        
        
        btnPenLine.setImage(UIImage(named: "penline"), forState: UIControlState.Normal);
        btnPenLine.setImage(UIImage(named: "penlineck"), forState: UIControlState.Selected);
        
        btnPenDashLine.setImage(UIImage(named: "pendashline"), forState: UIControlState.Normal);
        btnPenDashLine.setImage(UIImage(named: "pendashlineck"), forState: UIControlState.Selected);
        
        btnPenBox.setImage(UIImage(named: "penbox"), forState: UIControlState.Normal);
        btnPenBox.setImage(UIImage(named: "penboxck"), forState: UIControlState.Selected);
        
        btnPenCircle.setImage(UIImage(named: "pencircle"), forState: UIControlState.Normal);
        btnPenCircle.setImage(UIImage(named: "pencircleck"), forState: UIControlState.Selected);
        
        btnPenHLight.setImage(UIImage(named: "penhighlight"), forState: UIControlState.Normal);
        btnPenHLight.setImage(UIImage(named: "penhighlightck"), forState: UIControlState.Selected);
        
        btnPenEraser.setImage(UIImage(named: "peneraser"), forState: UIControlState.Normal);
        btnPenEraser.setImage(UIImage(named: "peneraserck"), forState: UIControlState.Selected);
        
        //日记Title图章按钮初始化
        btnStamp.setImage(UIImage(named: "stamp"), forState: UIControlState.Normal);
        btnStamp.setImage(UIImage(named: "stampck"), forState: UIControlState.Selected);
        btnStamp.addTarget(self,action:#selector(ViewController.doPenSwitch(_:)),forControlEvents:.TouchUpInside);//点击事件
        
        
        //为日记title图章添加长按事件
        var longPress=UILongPressGestureRecognizer(target: self, action: #selector(ViewController.doSetDiaryTitle(_:)));
        longPress.minimumPressDuration=0.4;
        btnStamp.addGestureRecognizer(longPress);
        
        
        
        //为页码标签框添加长按事件
        longPress=UILongPressGestureRecognizer(target: self, action: #selector(ViewController.doRemoveCurPage(_:)));
        longPress.minimumPressDuration=0.4;
        self.labPages.addGestureRecognizer(longPress);
        
        //插入图片按钮初始化
        btnInsertImg.setImage(UIImage(named: "insertimg"), forState: UIControlState.Normal);
        btnInsertImg.setImage(UIImage(named: "insertimgck"), forState: UIControlState.Selected);
        btnInsertImg.addTarget(self,action:#selector(ViewController.doPenSwitch(_:)),forControlEvents:.TouchUpInside);//点击事件
        
        
        
        //划动手势支持,added by shiww
        //上划关闭工具条
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipeGesture(_:)))
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up;
        
        swipeUpGesture.numberOfTouchesRequired=2;
        
        self.view.addGestureRecognizer(swipeUpGesture)
        //下划显示工具条
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipeGesture(_:)))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
        swipeDownGesture.numberOfTouchesRequired=2;
        self.view.addGestureRecognizer(swipeDownGesture)
        
        
        //added by shiww,加载最后一次保存的数据
        if !self.pages.loadPageMetainfo()
        {
            return;
        }
        
        let tempImage=self.pages.loadPage()
        self.board.loadImage(tempImage);
        self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let err = error {
            let alertController = UIAlertController(title: BaseFunction.getIntenetString("ERROR"), message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: BaseFunction.getIntenetString("CLOSE"), style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated:true,completion:nil);
            
        } else {
            let alertController = UIAlertController(title: BaseFunction.getIntenetString("INFO"), message: BaseFunction.getIntenetString("SAVE_SUCCEED"), preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated:true,completion:nil);
        }
    }
    
    @IBAction func doUndo(sender: UIButton) {
        self.undo();
    }
    
    @IBOutlet weak var labPages: UIButton!
    //MARK:- 页码操作
    //删除当前页
    
    func doRemoveCurPage(sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        if self.pages.PageCount<=1//只有一页,就不让删除了
        {
            return;
        }
        
        let alertController = UIAlertController(title: BaseFunction.getIntenetString("WARNING"), message: BaseFunction.getIntenetString("DELETE_PAGE_CONFIRM"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: BaseFunction.getIntenetString("CANCEL"), style: .Cancel) { (action) in
            
            return;//返回,不清空了!
            // ...
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: .Destructive) { (action) in
            self.pages.removePage();//执行删除操作
            let tempImage=self.pages.loadPage();
            self.board.loadImage(tempImage);
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
            //清除undo/redo
            self.board.clearUndoRedo();
            return;
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true,completion:nil);
        
        
    }
    //前一页
    @IBAction func prevPage(sender: UIButton) {
        //保存当前页
        self.pages.savePage(self.board.takeImage(false));
        self.pages.savePage(self.board.takeImage(true),forEvernote:true);
        
        //加载上一页
        if self.pages.CurrentPage>1
        {
            let tempImage=self.pages.prevPage();
            //清除undo/redo
            self.board.clearUndoRedo();
            self.board.addUndoImage(tempImage);
            self.board.loadImage(tempImage);
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
        }
        
    }
    //后一页
    @IBAction func nextPage(sender: UIButton)
    {
//        print(sender.tag)
        //保存当前页
        self.pages.savePage(self.board.takeImage(false));
        
        self.pages.savePage(self.board.takeImage(true),forEvernote:true);
        
        
        //是最后一页，则增加一页
        if self.pages.CurrentPage==self.pages.PageCount
        {
//            self.ShowNotice("info","Add new Page");
            
            self.pages.addPage();
            if self.pages.savePageMetainfo()
            {
                self.board.clearAll(true);
                self.self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
                //清除undo/redo
                self.board.clearUndoRedo();
            }
            return;
        }
        
        //加载下一页,如果不是最后一页

        if self.pages.CurrentPage<self.pages.PageCount
        {
//            self.ShowNotice("info","Toggle to next Page");

            let tempImage=self.pages.nextPage();
            //清除undo/redo
            self.board.clearUndoRedo();
            self.board.addUndoImage(tempImage);
            
            self.board.loadImage(tempImage);
            
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
            return;
            
        }

    }
    //清除当前页面内容
    @IBAction func clearCurPage(sender: AnyObject) {
        
        
        let alertController = UIAlertController(title:BaseFunction.getIntenetString("WARNING"), message:BaseFunction.getIntenetString("CLEAR_PAGE_CONFIRM"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title:BaseFunction.getIntenetString("CANCEL"), style: .Cancel) { (action) in
            
            return;//返回,不清空了!
            // ...
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: .Destructive) { (action) in
            self.board.clearAll()
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true,completion:nil);
    }
    //设置日记Title：设置所在城市
    func doSetDiaryTitle(sender : UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        let popVC=SetCurrentCityController();
        popVC.mainViewController=self;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        popVC.popoverPresentationController!.delegate = self
        let popOverController = popVC.popoverPresentationController
        popOverController!.sourceView = sender.view;
        popOverController!.sourceRect = sender.view!.bounds
        popVC.preferredContentSize=CGSizeMake(414,114);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)
    }
    //笔刷设置
    func doSetBrush(sender : UILongPressGestureRecognizer) {
        
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        let popVC=PaintingBrushSetting();
        popVC.mainViewController=self;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        popVC.popoverPresentationController!.delegate = self
        let popOverController = popVC.popoverPresentationController
        popOverController!.sourceView = sender.view;
        popOverController!.sourceRect = sender.view!.bounds
        popVC.preferredContentSize=CGSizeMake(455,268);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)
        
    }
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //保存为图片
    @IBAction func doSaveAlbum(sender: AnyObject) {
        self.saveToAlbum();
    }
    @IBAction func doRedo(sender: UIButton) {
        self.redo();
    }
    
    
    func undo() {
        self.board.undo()
    }
    
    func redo() {
        self.board.redo()
    }
    
    
    func saveToAlbum() {
        UIImageWriteToSavedPhotosAlbum(self.board.takeImage(), self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    
    
    func setBackgroundColor(image:UIImage)
    {
        //added by shiww,to support retina
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size,false,0);
        image.drawInRect(self.view.bounds);
        let tempImage=UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        //added end
        self.board.backgroundColor = UIColor(patternImage: tempImage);
        
        self.saveSystemPara();
        
    }
    
    //划动手势支持,确定是否显示工具条
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        //划动的方向
        let direction = sender.direction
        //判断是上下左右
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            //            print("Left")
            break
        case UISwipeGestureRecognizerDirection.Right:
            //            print("Right")
            break
        case UISwipeGestureRecognizerDirection.Up://关闭工具条
            //            print("Up")
            UIView.beginAnimations(nil, context: nil)
            topView.hidden=true;
            UIView.commitAnimations()
            break
        case UISwipeGestureRecognizerDirection.Down://打开工具条
            //            print("Down")
            UIView.setAnimationDelay(1.0)
            topView.hidden=false;
            UIView.commitAnimations()
            break
        default:
            break
        }
    }
    //保存系统参数
    func saveSystemPara()
    {
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、存储数据
        defaults.setObject(self.board.strokeWidth, forKey: "strokeWidth");
        defaults.setColor(self.board.strokeColor, forKey: "strokeColor");
        defaults.setObject(self.board.pencilSense, forKey: "pencilSense");
        //        print(self.board.backgroundColor);
        defaults.setObject(self.board.bkImgName, forKey: "bkImgName");
        defaults.setObject(self.city, forKey: "city");
        //  3、同步数据
        defaults.synchronize();
        
    }
    //加载系统参数
    private func loadSystemPara()
    {
        let defaults = NSUserDefaults.standardUserDefaults();
        if  (defaults.objectForKey("strokeWidth") != nil)
        {
            self.board.strokeWidth = defaults.objectForKey("strokeWidth") as! CGFloat;
        }
        if  (defaults.objectForKey("strokeColor") != nil)
        {
            self.board.strokeColor = defaults.colorForKey("strokeColor")!
        }
        if  (defaults.objectForKey("pencilSense") != nil)
        {
            self.board.pencilSense = defaults.objectForKey("pencilSense") as! CGFloat;
        }
        if  (defaults.objectForKey("bkImgName") != nil)
        {
            self.board.bkImgName = defaults.stringForKey("bkImgName")!;
        }
        else
        {
            self.board.bkImgName="background1";
        }
        if  (defaults.objectForKey("city") != nil)
        {
            self.city = defaults.stringForKey("city")!;
            
        }
        
        
    }
}


