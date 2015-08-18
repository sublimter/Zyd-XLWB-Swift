//
//  PhotoSelectorViewController.swift
//  01-照片选择
//
//  Created by apple on 15/7/10.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotoSelectorViewController: UIViewController, UICollectionViewDataSource, PhotoSelectorViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
        // 设置 layout 
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.lightGrayColor()

        collectionView.registerClass(PhotoSelectorViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.ff_Fill(view)
    }
    
    // MARK: 数据源方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 末尾显示加号按钮，以便添加照片
        return photos.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoSelectorViewCell
        
        // 设置图像
        // photos.count 是数组最后一项 + 1
        cell.image = (indexPath.item == photos.count) ? nil : photos[indexPath.item]
        
        cell.photoDelegate = self
        
        return cell
    }
    
    // MARK: - PhotoSelectorViewCellDelegate
    func photoSelectorSelectPhoto() {
        print(__FUNCTION__)
        // UIImagePickerController 专门用来选择照片的
        /**
            PhotoLibrary        照片库(所有的照片，拍照&用 iTunes & iPhoto `同步`的照片 - 不能删除)
            SavedPhotosAlbum    相册(自己拍摄的，可以随意删除)
            Camera              相机
        */
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            return
        }
        
        let picker = UIImagePickerController()
        
        // 设置代理
        picker.delegate = self

        // 允许编辑 － 如果要上传头像，记得把这个属性打开
        // 能够建立一个正方形的图像，方便后续的头像处理
        // * picker.allowsEditing = true
        
        // Modal 显示
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func photoSelectorDeletePhoto(cell: PhotoSelectorViewCell) {
        
        // indexPath
        let indexPath = collectionView.indexPathForCell(cell)
        
        // 删除照片
        photos.removeAtIndex(indexPath!.item)
        
        // 更新数据
        collectionView.reloadData()
    }
    
    // MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
    // 提示：所有关于相册的处理，都要处理内存！
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        // 获得图像
        print(image)
        // 提示：不要使用以下代码压缩
//        let data = UIImageJPEGRepresentation(image, 1.0)!
//        data.writeToFile("/Users/Apple/Desktop/123.jpg", atomically: true)
//        let data1 = UIImageJPEGRepresentation(image, 0.1)!
//        data1.writeToFile("/Users/Apple/Desktop/1234.jpg", atomically: true)
        
        // 将图像添加到数组
        photos.append(image.scaleImage(300))
        collectionView.reloadData()
        
        // 一旦实现了协议方法，就需要我们自己关闭
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: 懒加载
    private lazy var layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    /// 图像数组
    lazy var photos = [UIImage]()
}

@objc
protocol PhotoSelectorViewCellDelegate: NSObjectProtocol {
    ///  要选择照片
    optional func photoSelectorSelectPhoto()
    ///  要删除照片
    optional func photoSelectorDeletePhoto(cell: PhotoSelectorViewCell)
}

/// 照片选择 cell
class PhotoSelectorViewCell: UICollectionViewCell {
  
    // unwrapping an Optional value
    // 不能解包可选项 -> 将 nil 使用了惊叹号
    var image: UIImage? {
        didSet {
            
            if image != nil {
                photoButton.setImage(image, forState: UIControlState.Normal)
            } else {
                photoButton.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
                photoButton.setImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
            }
            
            removeButton.hidden = (image == nil)
        }
    }
    
    // 定义代理
    weak var photoDelegate: PhotoSelectorViewCellDelegate?
    
    // 如果使用 addTarget 设置监听方法，类不能是 private 的
    func selectPhoto() {
        
        // 必须要点击没有图像的按钮
        if image == nil {
            photoDelegate?.photoSelectorSelectPhoto!()
        }
    }
    
    func deletePhoto() {
        photoDelegate?.photoSelectorDeletePhoto!(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    private func prepareUI() {
        
        // 设置按钮的填充模式 - imageView
        photoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        // 添加控制
        addSubview(photoButton)
        addSubview(removeButton)
        
        // 设置布局
        photoButton.ff_Fill(self)
        removeButton.ff_AlignInner(ff_AlignType.TopRight, referView: self, size: nil)
        
        // 设置监听方法
        photoButton.addTarget(self, action: "selectPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        removeButton.addTarget(self, action: "deletePhoto", forControlEvents: UIControlEvents.TouchUpInside)
        
        // 默认删除按钮不显示
        removeButton.hidden = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    private lazy var photoButton: UIButton = PhotoSelectorViewCell.createButton("compose_pic_add")
    private lazy var removeButton: UIButton = PhotoSelectorViewCell.createButton("compose_photo_close")
    
    /// 创建按钮
    class func createButton(imageName: String) -> UIButton {
        let button = UIButton()
        
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        
        return button
    }
}

