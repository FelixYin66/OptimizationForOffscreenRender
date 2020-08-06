//
//  TableViewCell2.swift
//  OptimizationForOffScreenRenderTwo
//
//  Created by Felix Yin on 2020/8/6.
//  Copyright © 2020 Felix Yin. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    let imgView = UIImageView();
    
    let imgView2 = UIImageView();
    
    let lbl = UILabel();
    
    let lbl2 = UILabel();
    
    //没有出现离屏渲染问题，但在老项目中Main.storyBoard原有创建的UITableViewCell中UIImageView出现离屏渲染问题（iPhone 6 plus iOS 10.4）
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.contentView.addSubview(imgView);
        self.contentView.addSubview(imgView2)
        self.contentView.addSubview(lbl)
        self.contentView.addSubview(lbl2)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false;
        imgView.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true;
        imgView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true;
        imgView.image = UIImage(named: "L80.png");
        imgView.layer.cornerRadius = 10;
        imgView.layer.masksToBounds = true;
        imgView.tag = 10;
        
        
        imgView2.translatesAutoresizingMaskIntoConstraints = false;
        imgView2.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView2.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView2.leftAnchor.constraint(equalTo: imgView.rightAnchor, constant: 10).isActive = true;
        imgView2.centerYAnchor.constraint(equalTo: imgView.centerYAnchor, constant: 0).isActive = true;
        imgView2.image = UIImage(named: "R80.png");
        imgView2.layer.cornerRadius = 10;
        imgView2.layer.masksToBounds = true;
        imgView2.tag = 20;
        
        
        lbl.translatesAutoresizingMaskIntoConstraints = false;
        lbl.widthAnchor.constraint(equalToConstant: 150).isActive = true;
        lbl.heightAnchor.constraint(equalToConstant: 20).isActive = true;
        lbl.leftAnchor.constraint(equalTo: imgView2.rightAnchor, constant: 30).isActive = true;
        lbl.topAnchor.constraint(equalTo: imgView.topAnchor, constant:0).isActive = true;
        lbl.tag = 30;
        
        lbl2.translatesAutoresizingMaskIntoConstraints = false;
        lbl2.widthAnchor.constraint(equalToConstant: 150).isActive = true;
        lbl2.heightAnchor.constraint(equalToConstant: 20).isActive = true;
        lbl2.leftAnchor.constraint(equalTo: lbl.leftAnchor, constant: 0).isActive = true;
        lbl2.bottomAnchor.constraint(equalTo: imgView2.bottomAnchor, constant:0).isActive = true;
        lbl2.tag = 40;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}
