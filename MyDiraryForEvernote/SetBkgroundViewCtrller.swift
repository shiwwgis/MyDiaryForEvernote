//
//  SetBkgroundViewCtrller.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/2/22.
//  Copyright © 2016年 shiww. All rights reserved.
//

import UIKit

class SetBkgroundViewCtrller: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBAction func doSelimageFromAlbum(sender: UIButton) {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self;
        self.presentViewController(pickerController, animated: true, completion: nil);
    }
    var mainViewController:ViewController?;
    
    private let strImageName=["background1","background2","background3","background4","background5","background6","background7","background8","background9"];
    var imageIndex:Int=0;
    
    
    @IBAction func doSetbkCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);//关闭窗口
        
    }
    @IBAction func doSetbkOK(sender: AnyObject) {
        //设置背景
        let tempImage=imgBkground.image;
        
        if imageIndex<self.strImageName.count
        {
            mainViewController!.board.bkImgName=strImageName[imageIndex];
        }
        
        mainViewController!.setBackgroundColor(tempImage!);
        self.dismissViewControllerAnimated(true, completion: nil);
        
        
    }
    @IBAction func doPrevImage(sender: UIButton) {
        if imageIndex<=0//已是第一个
        {
            imageIndex=strImageName.count-1;
        }
        else
        {
            imageIndex=imageIndex-1;
        }
        
        let tempImage=UIImage(named: strImageName[imageIndex]);
        
        imgBkground.image=tempImage;
        
    }
    
    @IBAction func doNextImage(sender: UIButton) {
        if imageIndex>=strImageName.count-1//已是最后一个
        {
            imageIndex=0
        }
        else
        {
            imageIndex=imageIndex+1;
        }
        let tempImage=UIImage(named: strImageName[imageIndex]);
        imgBkground.image=tempImage;
    }
    
    @IBOutlet weak var imgBkground: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageIndex=strImageName.indexOf((mainViewController?.board.bkImgName)!)!;
        
        assert(imageIndex<strImageName.count);
        let tempImage=UIImage(named: strImageName[imageIndex]);
        imgBkground.image=tempImage;
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
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.imgBkground.image=image
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
