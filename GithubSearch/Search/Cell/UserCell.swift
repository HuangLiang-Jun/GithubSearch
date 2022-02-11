//
//  UserCell.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import UIKit
import SnapKit
import SDWebImage

class UserCell: UICollectionViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "mike"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        avatarImageView.image = nil
    }
    
    private func setupLayout() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.size.equalTo(contentView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(with user: UserModel) {
        avatarImageView.sd_setImage(with: user.avatarURL)
        nameLabel.text = user.name
    }
}
