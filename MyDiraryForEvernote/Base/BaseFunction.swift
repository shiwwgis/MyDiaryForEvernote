//
//  BaseFunction.swift
//  MyDiaryForEvernote
//
//  Created by shiweiwei on 16/2/26.
//  Copyright © 2016年 shiww. All rights reserved.
//

import Foundation

class BaseFunction:NSObject
{
    //根据城市获取天气状态
    static func  getCityWeather(city: String)->String {
        let url = "http://apis.baidu.com/heweather/weather/free"
        let spacelessString =        city.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet());

        //city.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);

        let httpArg = "city="+spacelessString!;
        
        var strWeather:String="";
        
        let req = NSMutableURLRequest(URL: NSURL(string: url + "?" + httpArg)!)
        req.timeoutInterval = 6
        req.HTTPMethod = "GET"
        req.addValue("4a21ed362d7f05ac4ae1604665de9a9d", forHTTPHeaderField: "apikey")
        
//        print(req);
        
        let session=NSURLSession.sharedSession();
        
        let semaphore = dispatch_semaphore_create(0)
        
        
        let task=session.dataTaskWithRequest(req)
            {
                (data, response, error) -> Void in
//                let res = response as! NSHTTPURLResponse;
               // print(res.statusCode)


                
                if  error != nil {
                    //                print("请求失败")
                }
                if data != nil
                {
                    //处理JSON
                    let json = JSON(data: data!);
                    
                   // print(json);
                    
                    let result=json["HeWeather data service 3.0",0,"status"].string!;
                    
                    if result=="ok"
                    {
                    
                    strWeather=json["HeWeather data service 3.0",0,"basic","city"].string!;//城市名
                    strWeather=strWeather+":"+json["HeWeather data service 3.0",0,"now","cond","txt"].string!;//实况天气
                    
                    if json["HeWeather data service 3.0",0,"aqi","city","pm25"].string != nil
                    {
                        strWeather=strWeather+" PM2.5:"+json["HeWeather data service 3.0",0,"aqi","city","pm25"].string!;//PM2.5
                    }
                    }
                }
                dispatch_semaphore_signal(semaphore);
        }
        
        //使用resume方法启动任务
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return strWeather;
    }

    //生成日期+天气的字符串
    static func getDiaryTitle(cityname:String="Beijing")->String
    {
        var strDiaryTitle:String="";
        
        let dateFormatter=NSDateFormatter();
        dateFormatter.dateFormat="YYYY-MM-dd EEEE   "
        strDiaryTitle="\(dateFormatter.stringFromDate(NSDate()))";
        
        strDiaryTitle=strDiaryTitle+BaseFunction.getCityWeather(cityname);
        
        return strDiaryTitle;
        
    }
    
    //返回国际化字符串
    static func getIntenetString(key:String)->String{
        let string=NSLocalizedString(key,comment:"");
//        print("key=\(key),string=\(string)");
        return string;
    }

}
