//
//  TableViewCell.swift
//  OffscreenRenderDemo
//
//  Created by Felix Yin on 2020/8/6.
//  Copyright © 2020 seedante. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    let imgView = UIImageView();
    
    //没有出现离屏渲染问题，但在老项目中Main.storyBoard原有创建的UITableViewCell中UIImageView出现离屏渲染问题（iPhone 6 plus iOS 10.4）
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.contentView.addSubview(imgView);
        
        imgView.translatesAutoresizingMaskIntoConstraints = false;
        imgView.widthAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView.heightAnchor.constraint(equalToConstant: 80).isActive = true;
        imgView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true;
        imgView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true;
        imgView.image = UIImage(named: "L80.png");
        imgView.layer.cornerRadius = 10;
        imgView.layer.masksToBounds = true;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}
