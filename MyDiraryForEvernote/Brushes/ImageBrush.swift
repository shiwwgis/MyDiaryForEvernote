//
//  ImageBrush.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/3/3.
//  Copyright © 2016年 zhangao. All rights reserved.
//


import UIKit

class ImageBrush: BaseBrush {
    
    var image:UIImage?=UIImage(named: "AboutSystem");
    
    
    override func drawInContext(context: CGContextRef) {
        //开始绘制
        if image==nil
        {
            return;
        }
        
        let trueRect=CGRect(origin: CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y)),
            size: CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y)));
        
        //按比例缩放适应绘图区域,居中绘制,计算新的矩形
        var imageX=self.image!.size.width;
        var imageY=self.image!.size.height;
        
        
        let scale=min(trueRect.height/imageY,trueRect.width/imageX);
        
        imageX=imageX*scale;
        imageY=imageY*scale;
        
        var imageOrigin=CGPoint();
        
        imageOrigin.x=trueRect.origin.x+(trueRect.width-imageX)/2;
        imageOrigin.y=trueRect.origin.y+(trueRect.height-imageY)/2;
        
        let imageRect=CGRectMake(imageOrigin.x, imageOrigin.y, imageX,imageY);
        
        image?.drawInRect(imageRect);

        
        //绘原始矩形
        
       // CGContextAddRect(context, trueRect);
    }
}
