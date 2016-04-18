//
//  Board.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-15.
//  modified by Shiweiwei on 16-3-02
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

enum DrawingState {
    case Began, Moved, Ended
}

class Pages:NSObject
{
    var Caption:String="";
    var PageCount:Int=1;
    var WriteDateTime:String="";
    var UploadDateTime:String="";
    var Tag:Int=0;
    var CurrentPage:Int=1;
    private var PageList=[String](["temp1"]);
    
    func addPage()//增加一个页面
    {
        PageCount=PageCount+1;
        let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
        let strTemp=uuid;
        PageList.append(strTemp);
        CurrentPage=CurrentPage+1;
    }
    
    func removePage()//删除当前页
    {
        PageList.removeAtIndex(CurrentPage-1);
        if CurrentPage>1
        {
            CurrentPage=CurrentPage-1;
        }
        
        PageCount=PageCount-1;
        
    }
    
    func loadPage(forEvernote:Bool=false,pageIndex:Int = -1)->UIImage
    {
        var realPageIndex=0;
        if pageIndex == -1//没有指定页面
        {
            realPageIndex=CurrentPage;
            
        }
        else
        {
            realPageIndex=pageIndex;
        }
        
        
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        var pagefilePath=docDir+"/"+PageList[realPageIndex-1];
        
        if forEvernote
        {
            pagefilePath=pagefilePath+"_ev.png";
        }
        else
        {
            pagefilePath=pagefilePath+".png";
            
        }
        
//        print("load from "+pagefilePath);
        
        if let tmpImage=UIImage(contentsOfFile: pagefilePath)
        {
            return tmpImage;
        }
        else
        {
            return UIImage();
        }
        
    }
    //加载pages元数据
    func loadPageMetainfo()->Bool
    {
        /// 1、获得沙盒的根路径
        let home = NSHomeDirectory() as NSString;
        /// 2、获得Documents路径，使用NSString对象的stringByAppendingPathComponent()方法拼接路径
        let docPath = home.stringByAppendingPathComponent("Documents") as NSString;
        /// 3、获取文本文件路径
        let filePath = docPath.stringByAppendingPathComponent("PagesMetainfo.plist");
        let dataSource = NSArray(contentsOfFile: filePath);
        if dataSource != nil
        {
            
            self.Caption=dataSource![0] as! String;
            self.PageCount=dataSource![1] as! Int;
            self.Tag=dataSource![2] as! Int;
            self.WriteDateTime=dataSource![3] as! String;
            self.UploadDateTime=dataSource![4] as! String;
            self.PageList=dataSource![5] as! [String];
            
            //            Swift.debugPrint("\(dataSource)");
            return true;
        }
        else
        {
            return false;
        }
        
    }
    //加载Pages元数据
    func savePageMetainfo()->Bool
    {
        /// 1、获得沙盒的根路径
        let home = NSHomeDirectory() as NSString;
        /// 2、获得Documents路径，使用NSString对象的stringByAppendingPathComponent()方法拼接路径
        let docPath = home.stringByAppendingPathComponent("Documents") as NSString;
        /// 3、获取文本文件路径
        let filePath = docPath.stringByAppendingPathComponent("PagesMetainfo.plist");
        let dataSource = NSMutableArray();
        
        let dateFormatter=NSDateFormatter();
        dateFormatter.dateFormat="YYYY-MM-dd HH:mm:ss"
        WriteDateTime=dateFormatter.stringFromDate(NSDate());
        Caption=BaseFunction.getIntenetString("DIARY")+WriteDateTime;
        
        dataSource.addObject(Caption);
        dataSource.addObject(PageCount);
        //        dataSource.addObject(pagePrefix);
        dataSource.addObject(Tag);
        dataSource.addObject(WriteDateTime);
        dataSource.addObject(UploadDateTime);
        dataSource.addObject(PageList);
        // 4、将数据写入文件中
        dataSource.writeToFile(filePath, atomically: true);
        //        Swift.debugPrint("\(filePath)");
        return true;
    }
    //保存当前page
    func savePage(image:UIImage,forEvernote:Bool=false)->Bool
    {
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        var pagefilePath=docDir+"/"+PageList[CurrentPage-1];
//        print("pagepreix=\(PageList[CurrentPage-1])");
        if forEvernote
        {
            pagefilePath=pagefilePath+"_ev.png";
        }
        else
        {
            pagefilePath=pagefilePath+".png";
            
        }
        
//        print("Save into "+pagefilePath);

        
        let saveResult=UIImagePNGRepresentation(image)!.writeToFile(pagefilePath, atomically: true);
        
        return saveResult;
        
    }
    func nextPage()->UIImage
    {
        CurrentPage=CurrentPage+1;
        assert(CurrentPage>=1 && CurrentPage<=PageCount);
        /*if CurrentPage<=0
        {
        CurrentPage=0;
        }*/
        
        return self.loadPage();
    }
    
    func prevPage()->UIImage
    {
        CurrentPage=CurrentPage-1;
        assert(CurrentPage>=1 && CurrentPage<=PageCount);
        /*if CurrentPage>=self.PageCount-1
        {
        CurrentPage=0;
        }*/
        return self.loadPage();
    }
    
    func uploadToEvernote()->Bool
    {
        return true;
    }
    
}

class Board: UIImageView {
    
    private var eraserCursor:UIImageView?;
    private var pencilTouch:UITouch?;//added by shiww
    private var pencilEvent: UIEvent?;//added by shiww
    var bkImgName:String="background1";//added by shiww,背影图片名称
    
    private func initEraserCursor()
    {
        eraserCursor=UIImageView(frame: CGRectMake(0,0,20,20));
        eraserCursor?.contentMode = .ScaleToFill;
        eraserCursor?.image=UIImage(named:"Eraser");
        eraserCursor?.tag=761;
        eraserCursor?.hidden=true;
    }
    //初始化绘图环境
    private var contextInited:Bool=false;
    private var drawContext:CGContextRef?;
    private func initContext()
    {
        if !contextInited
        {
            let scale = self.window!.screen.scale
            UIGraphicsBeginImageContextWithOptions(self.bounds.size,false,scale);//支持ipad pro
            
            
            drawContext = UIGraphicsGetCurrentContext();
            
            
            UIColor.clearColor().setFill()
            UIRectFill(self.bounds)
            
            CGContextSetLineCap(drawContext, CGLineCap.Round)
            CGContextSetStrokeColorWithColor(drawContext, self.strokeColor.CGColor)
            
            if let realImage = self.realImage
            {
                realImage.drawInRect(self.bounds)
            }
            
            contextInited=true;
        }
        
    }
    // UndoManager，用于实现 Undo 操作和维护图片栈的内存
    private class DBUndoManager {
        class DBImageFault: UIImage {}  // 一个 Fault 对象，与 Core Data 中的 Fault 设计类似
        
        private static let INVALID_INDEX = -1
        private var images = [UIImage]()    // 图片栈
        private var index = INVALID_INDEX   // 一个指针，指向 images 中的某一张图
        private static let cahcesLength = 5 // 在内存中保存图片的张数，以 index 为中心点计算：cahcesLength * 2 + 1
        
        
        var canUndo: Bool {
            get {
                return index>0;// != DBUndoManager.INVALID_INDEX
            }
        }
        
        var canRedo: Bool {
            get {
                return index + 1 < images.count
            }
        }
        //added by shiww,清队Undo Redo队列
        func clearUndoRedo()
        {
            index = DBUndoManager.INVALID_INDEX;
            images.removeAll();
            
        }
        func addImage(image: UIImage) {
            //added by shiww,超出undo/redo总长度,则首端,后面的依次前移
            //images.count总数应为cahcesLength+1;
            
            if index == DBUndoManager.cahcesLength
            {
                //清除首端
                //                Swift.debugPrint("cahcesLength-1=\(DBUndoManager.cahcesLength-1),index=\(index)");
                
                images.removeFirst();
            }
            
            // 当往这个 Manager 中增加图片的时候，先把指针后面的图片全部清掉，
            // 这与我们之前在 drawingImage 方法中对 redoImages 的处理是一样的
            if index < images.count - 1 {
                images[index + 1 ... images.count - 1].removeAll();// = []
            }
            images.append(image)
            
            // 更新 index 的指向
            index = images.count - 1
            
            //            Swift.debugPrint("images count=\(images.count),index=\(index)");
            
            setNeedsCache()
        }
        
        func imageForUndo() -> UIImage? {
            var image: UIImage? = nil
            if self.canUndo {
                index -= 1;
                setNeedsCache()
                image = images[index]
            }
            return image;
        }
        
        func imageForRedo() -> UIImage? {
            var image: UIImage? = nil
            if self.canRedo {
                index=index+1;
                image = images[index]//++index;
            }
            setNeedsCache()
            return image
        }
        
        // MARK: - Cache
        
        private func setNeedsCache() {
            return;//取消对Undo/redo的缓存文件支持
            /*
            if images.count >= DBUndoManager.cahcesLength {
                
                
                
                let location = max(0, index - DBUndoManager.cahcesLength)
                let length = min(images.count - 1, index + DBUndoManager.cahcesLength)
                for i in location ... length {
                    autoreleasepool {
                        let image = images[i]
                        
                        if i > index - DBUndoManager.cahcesLength && i < index + DBUndoManager.cahcesLength {
                            setRealImage(image, forIndex: i) // 如果在缓存区域中，则从文件加载
                        } else {
                            setFaultImage(image, forIndex: i) // 如果不在缓存区域中，则置成 Fault 对象
                        }
                    }
                }
            }*/
        }
        
        private static var basePath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        private func setFaultImage(image: UIImage, forIndex: Int) {
            if !image.isKindOfClass(DBImageFault.self) {
                let imagePath = (DBUndoManager.basePath as NSString).stringByAppendingPathComponent("\(forIndex)")
                UIImagePNGRepresentation(image)!.writeToFile(imagePath, atomically: false)
                images[forIndex] = DBImageFault()
            }
        }
        
        private func setRealImage(image: UIImage, forIndex: Int) {
            if image.isKindOfClass(DBImageFault.self) {
                let imagePath = (DBUndoManager.basePath as NSString).stringByAppendingPathComponent("\(forIndex)")
                images[forIndex] = UIImage(data: NSData(contentsOfFile: imagePath)!)!
            }
        }
    }
    
    var brush: BaseBrush?
    
    var strokeWidth: CGFloat=1.0;//笔基准宽度
    var strokeColor: UIColor=UIColor.blackColor();//笔颜色
    var pencilSense:CGFloat=0.8;//Apple Pencile圧感灵敏程度
    
    
    
    private var realImage: UIImage?
    
    private var boardUndoManager = DBUndoManager() // 缓存或Undo控制器
    
    private var drawingState: DrawingState!
    
    override init(frame: CGRect) {
        self.strokeColor = UIColor.blackColor()
        self.strokeWidth = 1
        super.init(frame: frame);
        self.initEraserCursor();
        //支持多点触摸
        self.multipleTouchEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.strokeColor = UIColor.blackColor()
        self.strokeWidth = 1
        super.init(coder: aDecoder)
        self.initEraserCursor();
        //支持多点触摸
        self.multipleTouchEnabled = true
        
    }
    
    // MARK: - Public methods
    
    var canUndo: Bool {
        get {
            return self.boardUndoManager.canUndo
        }
    }
    
    var canRedo: Bool {
        get {
            return self.boardUndoManager.canRedo
        }
    }
    
    // undo 和 redo 的逻辑都有所简化
    func undo() {
        if self.canUndo == false {
            return
        }
        
        self.image = self.boardUndoManager.imageForUndo()
        
        self.realImage = self.image
    }
    
    func redo() {
        if self.canRedo == false {
            return
        }
        
        self.image = self.boardUndoManager.imageForRedo()
        
        self.realImage = self.image
    }
    //MARK:-清除undoredo cache
    func clearUndoRedo()
    {
        self.boardUndoManager.clearUndoRedo();
    }
    //Mark:-加一个IMAGE到缓存池中
    func addUndoImage(image:UIImage)
    {
        self.boardUndoManager.addImage(image);
    }
    
    func loadImage(image:UIImage) {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,false,0.0);
        self.image=image;
        self.realImage=image;
        UIGraphicsEndImageContext();
        
    }
    //added by shiww,清除当前页面所绘内容
    func clearAll(isPageChanged:Bool=false)
    {
        let scale = self.window!.screen.scale
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,false,scale);//支持ipad pro
        
        let context = UIGraphicsGetCurrentContext();
        
        
        CGContextClearRect(context,self.bounds);
        let clearimage = UIGraphicsGetImageFromCurrentImageContext();
        
        self.image=clearimage;
        self.realImage=clearimage;
        
        if !isPageChanged
        {
            self.boardUndoManager.addImage(self.image!)//增加undo/redo的支持
        }
        
        UIGraphicsEndImageContext()
        
        
    }
    
    
    
    func takeImage(isSaveBkcolor:Bool=true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,false,0.0)
        let tempbounds=self.bounds;
        
        if isSaveBkcolor//保存绘图数据时控制是否连背影一起保存,true保存否则不保存added by shiww
        {
            self.backgroundColor?.setFill()
            
            UIRectFill(tempbounds)
        }
        
        //         Swift.debugPrint(tempbounds);
        
        self.image?.drawInRect(tempbounds)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //         Swift.debugPrint(image.description);
        
        return image
    }
    
    // MARK: - touches methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count>=2
        {
            return;
        }
        
        //只支持apple pencil
        #if RELEASE
            if touches.first!.type != .Stylus
            {
                return;
            }
        #endif
        
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.preciseLocationInView(touches.first!.view);
            
            brush.endPoint = brush.beginPoint
            
            brush.force = (touches.first!.type == .Stylus || touches.first!.force > 0) ? touches.first!.force : 1.0;
            //added by shiww
            
            
            self.drawingState = .Began
            
            //为pencil brush初始化
            self.pencilTouch=touches.first!;
            self.pencilEvent=event;
            
            
            if brush is EraserBrush
            {
                let eraserSize=(brush as! EraserBrush).eraserStrokeWith;
                let newFrame=CGRectMake(brush.endPoint.x-eraserSize/2,brush.endPoint.y-eraserSize/2,eraserSize,eraserSize);
                self.eraserCursor?.frame=newFrame;
                eraserCursor?.hidden=false;
                self.addSubview(eraserCursor!);
            }
            
            self.drawingImage()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count>=2
        {
            return;
        }
        //只支持apple pencil
        #if RELEASE
            if touches.first!.type != .Stylus
            {
                return;
            }
        #endif
        
        if let brush = self.brush {
            brush.endPoint = touches.first!.preciseLocationInView(touches.first!.view);
            
            brush.force = (touches.first!.type == .Stylus || touches.first!.force > 0) ? touches.first!.force :1.0;//
            //added by shiww
            
            //为pencil brush初始化
            self.pencilTouch=touches.first!;
            self.pencilEvent=event;
            
            
            self.drawingState = .Moved
            
            self.drawingImage();
            
            if brush is EraserBrush
            {
                let eraserSize=(brush as! EraserBrush).eraserStrokeWith;
                let newFrame=CGRectMake(brush.endPoint.x-eraserSize/2,brush.endPoint.y-eraserSize/2,eraserSize,eraserSize);
                self.eraserCursor?.frame=newFrame;
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count>=2
        {
            return;
        }
        
        //只支持apple pencil
        #if RELEASE
            if touches.first!.type != .Stylus
            {
                return;
            }
        #endif
        
        if let brush = self.brush {
            brush.endPoint = touches.first!.preciseLocationInView(touches.first!.view);
            
            self.drawingState = .Ended
            
            if brush is EraserBrush
            {
                eraserCursor?.hidden=true;
                eraserCursor?.removeFromSuperview();
            }
            
            self.drawingImage()
            
        }
    }
    
    // MARK: - drawing
    
    private func drawingImage() {
        if let brush = self.brush {
            
            if self.drawingState == .Began
            {
                //处理一下undo/redo
                if self.boardUndoManager.images.count==0//是空的
                {
                    if self.image != nil
                    {
                        self.boardUndoManager.addImage(self.image!);
                    }
                }
                return;
            }
            
            
            self.initContext();
            
            brush.strokeWidth = self.strokeWidth
            brush.pencilSense = self.pencilSense;
            
            if  self.pencilTouch!.type == .Stylus && brush is PencilBrush//处理铅笔的连续性
            {
                var touches = [UITouch]()
                
                // Coalesce Touches
                // 2
                if let coalescedTouches = self.pencilEvent?.coalescedTouchesForTouch(self.pencilTouch!) {
                    touches = coalescedTouches;
                }
                else
                {
                    touches.append(self.pencilTouch!)
                }
                
                // 4
                //                  Swift.debugPrint("coalescedTouches count=\(touches.count)")
                
                for touch in touches
                {
                    let pencilBrush=brush as! PencilBrush;
                    pencilBrush.drawStroke(drawContext, touch: touch,view:self);
                    CGContextStrokePath(drawContext);
                    
                }
                
                
            }
            else
            {
                brush.drawInContext(drawContext!);
                CGContextStrokePath(drawContext)
            }
            
            
            
            
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            
            if self.drawingState == .Ended || brush.supportedContinuousDrawing()
            {
                self.realImage = previewImage
            }
            
            if brush.supportedContinuousDrawing()//铅笔,橡皮和高亮
            {
                if self.drawingState == .Ended
                {
                    UIGraphicsEndImageContext();
                    self.contextInited=false;
                }
            }
            else
            {
                UIGraphicsEndImageContext();
                self.contextInited=false;
            }
            
            // 用 Ended 事件代替原先的 Began 事件
            if self.drawingState == .Ended {
                self.boardUndoManager.addImage(self.image!)
            }
            
            self.image = previewImage
            
            brush.lastPoint = brush.endPoint
        }
    }
    
}
