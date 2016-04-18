//
//  SetCurrentCityController.swift
//  MyDiaryForEvernote
//
//  Created by shiweiwei on 16/2/27.
//  Copyright © 2016年 shiww. All rights reserved.
//

import UIKit

//设置当前所在城市

class SetCurrentCityController: UIViewController {
    
    @IBOutlet weak var textCity: UITextField!
    var mainViewController:ViewController?;
    
    @IBAction func doSetCity(sender: UIButton) {
        let cityname=textCity.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())//"!去掉两边的空格
        print(cityname);
        let weather=BaseFunction.getCityWeather(cityname);
        if weather.characters.count==0
        {
            textCity.text=BaseFunction.getIntenetString("INPUT_AGAIN");
        }
        else
        {
            mainViewController?.city=cityname;
            mainViewController?.saveSystemPara();
            self.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        textCity.text=mainViewController?.city;
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
