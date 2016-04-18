//
//  UploadToEvernoteController.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/2/18.
//  Copyright © 2016年 zhangao. All rights reserved.
//

import UIKit

class UploadToEvernoteController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var currentNoteBook:ENNotebook?;
    private var notebookLists=[ENNotebook]();
    
    @IBAction func doLogout(sender: UIButton) {
        ENSession.sharedSession().unauthenticate();
        //关闭窗口
        self.dismissViewControllerAnimated(true, completion: nil);

    }
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    var mainViewController:ViewController?;
    @IBOutlet weak var txtNoteTab: UITextField!
    @IBOutlet weak var txtNoteCaption: UITextField!
    @IBOutlet weak var pkvNotebook: UIPickerView!
    //关闭当前窗口
    @IBAction func doCloseWnd(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBOutlet weak var btnUpload: UIButton!
    //执行同步功能
    @IBAction func doUploadToEvernote(sender: UIButton)
    {
        if !ENSession.sharedSession().isAuthenticated
        {
            self.ShowNotice("SORRY","EVERNOTE_LOGIN_ FAILED");
            //            SwiftNotice.showNoticeWithText(NoticeType.error, text: "evernote login failed!", autoClear:true, autoClearTime: 1);
            return;
        };
        
        let pages=(mainViewController?.pages)!;
        if pages.PageCount<=0
        {
            return;
        }
        
//        self.ShowNotice("SYSTEMINFO","UPLOAD_EVERNOTE_NOW");
        
        btnUpload.enabled=false;

        
        
        mainViewController?.saveCurrentPages(UIButton());//保存一下当前页面
        
        var tempImage:UIImage;
        let note=ENNote();
        //设置标题
        note.title=self.txtNoteCaption.text;
        //设置Tag
        if self.txtNoteTab.text != ""
        {
            note.tagNames=["notetag"];
            note.tagNames[0]=self.txtNoteTab.text!;
        }
        //载入图片
        var contentString="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n"
        
        contentString=contentString+"<en-note style=\"padding: 15px 15px 1px 15px;text-align:center;background-color:#eef2f3;\">\n"
        
        contentString=contentString+"<div>\n";
        

        for i in 1...pages.PageCount
        {
            tempImage=pages.loadPage(true, pageIndex: i);
            
            let resource=ENResource(image: tempImage);
            
            
            note.addResource(resource);
            
            let strImage="<div style=\"padding: 0px 0px 0px 0px;margin-bottom:15px;\">\n<div style=\"max-width:750px;margin:0px auto 0px auto;padding:0px 0px 0px 0px;display:block;background-color:white;background-color:#ffffff;box-shadow:0px 1px 3px rgba(0,0,0,.25);-webkit-box-shadow:0px 1px 3px rgba(0,0,0,.25);border-radius:4px;\">";
            
            
            
            var strTemp=resource.mediaTag();
            
            strTemp=strTemp.stringByReplacingOccurrencesOfString("/>", withString: " style=\"margin: 0px; padding:0px; border-radius:4px;\"/>\n</div>\n</div>");
            
            strTemp=strImage+strTemp;
            
//            print(strTemp);
            
            
            contentString=contentString+strTemp;

        }

        contentString=contentString+"</div>\n</en-note>";
        
        
        let notecontent=ENNoteContent.init(ENML: contentString);

        
       
//        print(contentString);
        
        note.content=notecontent;
        
         //上传至evernote
        ENSession.sharedSession().uploadNote(note, notebook:self.currentNoteBook){(noteref:ENNoteRef?, err: NSError!) -> Void in
            if noteref != nil
            {
  
                //关闭窗口
                self.dismissViewControllerAnimated(true)
                {
                
                self.mainViewController!.ShowNotice("SYSTEMINFO","UPLOAD_EVERNOTE_SUCCEED");
                //                SwiftNotice.showNoticeWithText(NoticeType.info, text: "成功保存到Evernote!", autoClear:true, autoClearTime: 1);
                }

            }
            else
            {
                self.ShowNotice("SORRY","UPLOAD_EVERNOTE_FAIL");
                
                //                SwiftNotice.showNoticeWithText(NoticeType.error, text: "保存到Evernote失败!", autoClear:true, autoClearTime: 1);
                self.btnUpload.enabled=false;

            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        pkvNotebook.dataSource=self;
        //将delegate设置成自己
        pkvNotebook.delegate=self;
        
        self.ShowNotice("SYSTEMINFO","LOGIN_EVERNOTE_NOW");
        //执行evernote链接
        
        if !ENSession.sharedSession().isAuthenticated
        {
            self.ShowNotice("SORRY","EVERNOTE_LOGIN_ FAILED");
            
            //            SwiftNotice.showNoticeWithText(NoticeType.error, text: "evernote login failed!", autoClear:true, autoClearTime: 1);
            return;
        };
        
        txtUserName.text=ENSession.sharedSession().userDisplayName;//显示登录的用户名
        
        
        self.ShowNotice("SYSTEMINFO","LOAD_INFO_NOW");
        
        //       let semaphore = dispatch_semaphore_create(0)
        
        //开始列出笔记本
        let mySession=ENSession.sharedSession();
        
        
        mySession.listNotebooksWithCompletion
            {

                (noteBooks :[AnyObject]!, b : NSError!) -> Void in print(noteBooks, terminator: "");
                var enNoteBook:ENNotebook;
                var strNotebook="";
                if !noteBooks.isEmpty
                {
                    self.currentNoteBook=noteBooks[0] as? ENNotebook;
                    self.notebookLists.removeAll();
                    
                    for noteBook in noteBooks
                    {
                        enNoteBook=noteBook as! ENNotebook;
                        strNotebook="\(enNoteBook.name)";
                        self.notebookLists.append(enNoteBook);
                        //                        Swift.debugPrint("notebook:\(strNotebook)");
                        
                    }
                    //重新加载pkview
                    self.pkvNotebook.reloadAllComponents();
                    
                    self.ShowNotice("SYSTEMINFO","LOAD_INFO_SUCCEED");
                    
                    //日期格式
                    let dateFormatter=NSDateFormatter();
                    dateFormatter.dateFormat="YY-MM-dd HH:mm"
                    self.txtNoteCaption.text=BaseFunction.getIntenetString("DIARY")+"["+"\(dateFormatter.stringFromDate(NSDate()))]";
                    self.txtNoteTab.text="2016"+BaseFunction.getIntenetString("DIARY");
                    
                    
                }
                
                //                dispatch_semaphore_signal(semaphore);
                
                
        }
        
        //      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
    }
    //设置选择框的列数为1列,继承于UIPickerViewDataSource协议
    func numberOfComponentsInPickerView( pickerView: UIPickerView) -> Int{
        return 1;
    }
    
    //初始设置选择框的行数为1行，继承于UIPickerViewDataSource协议
    func pickerView(pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int{
        if notebookLists.isEmpty
        {
            return 1;
        }
        else
        {
            return notebookLists.count;
        }
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
        -> String? {
            if notebookLists.isEmpty
            {
                return BaseFunction.getIntenetString("DONT_HAVE_NOTEBOOK");
            }
            else
            {
                let enNoteBook=self.notebookLists[row] ;
                let strNotebook="\(enNoteBook.name)";
                
                return strNotebook;
            }
    }
    
    // 选中笔记本行的操作
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if self.notebookLists.count>0
        {
            self.currentNoteBook=self.notebookLists[row];
        }
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
    
}
