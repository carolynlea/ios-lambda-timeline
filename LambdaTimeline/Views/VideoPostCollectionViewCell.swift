//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Carolyn Lea on 10/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var videoView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var labelBackgroundView: UIView!
    @IBOutlet var authorLabel: UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        videoView = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews()
    {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    func setupLabelBackgroundView()
    {
        labelBackgroundView.layer.cornerRadius = 8
        
        labelBackgroundView.clipsToBounds = true
    }
    
    func setVideo(_ image: UIImage?)
    {
        let player = AVPlayer(url: (post?.mediaURL)!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        self.layer.addSublayer(playerLayer)
        player.play()
    }
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
}
