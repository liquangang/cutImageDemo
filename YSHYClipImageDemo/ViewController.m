//
//  ViewController.m
//  YSHYClipImageDemo
//
//  Created by 杨淑园 on 15/12/17.
//  Copyright © 2015年 yangshuyaun. All rights reserved.
//

#import "ViewController.h"
#import "YSHYClipViewController.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ClipViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UIImagePickerController * imagePicker;
    UIButton * btn;
    ClipType clipType;
    UIButton * circleBtn;
    UIButton * squareBtn;
    UITextField * textField ;
    CGFloat radius;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *txuImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ConfigUI];
}

-(void)ConfigUI
{
    btn = [UIButton buttonWithType:UIButtonTypeCustom]
    ;
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(self.view.frame.size.width/ 2 - 50, 100, 100, 100)];
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UILabel *label = [[UILabel alloc]init];
    [label setText:@"上传头像"];
    [label setFont:[UIFont systemFontOfSize:18.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFrame:CGRectMake(self.view.frame.size.width/ 2 - 50, 215, 100, 15)];
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/ 2 - 110, 240, 150, 25)];
    [label1 setText:@"选择裁剪类型:"];
    [self.view addSubview:label1];
    
    circleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [circleBtn setBackgroundColor:[UIColor redColor]];
    [circleBtn setFrame:CGRectMake(self.view.frame.size.width/ 2 - 90, 270, 100, 20)];
    [circleBtn setTitle:@"圆形裁剪" forState:UIControlStateNormal];
    [circleBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:circleBtn];
    
    squareBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [squareBtn setFrame:CGRectMake(self.view.frame.size.width/ 2 + 10, 270, 100, 20)];
    [squareBtn setTitle:@"方形裁剪" forState:UIControlStateNormal];
    [squareBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:squareBtn];
    
    textField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/ 2 - 110, 300, 210, 25)];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"请输入裁剪半径 默认120";
    [self.view addSubview:textField];
    
    [self.view addSubview:self.txuImageView];
    [self.view addSubview:self.imageView];
    
    self.imageView.userInteractionEnabled = YES;
    
    //pan手势 移动位置
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    
    [self.imageView addGestureRecognizer:pan];
    //rotation旋转手势
    UIRotationGestureRecognizer * rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotation:)];
    rotation.delegate = self;
    
    [self.imageView addGestureRecognizer:rotation];
    //pinch捏合手势
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    
    [self.imageView addGestureRecognizer:pinch];
}
-(void)selectedClipType:(UIButton *)sender
{
    [sender setBackgroundColor:[UIColor redColor]];
    if([sender.titleLabel.text isEqualToString:@"圆形裁剪"])
    {
        clipType = CIRCULARCLIP;
        [squareBtn setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        clipType = SQUARECLIP;
        [circleBtn setBackgroundColor:[UIColor whiteColor]];
    }
}
-(void)btnClick:(UIButton *)btn
{
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - imagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = info[@"UIImagePickerControllerOriginalImage"];
    
    YSHYClipViewController * clipView = [[YSHYClipViewController alloc]initWithImage:image];
    clipView.delegate = self;
    clipView.clipType = clipType; //支持圆形:CIRCULARCLIP 方形裁剪:SQUARECLIP   默认:圆形裁剪
    if(![textField.text isEqualToString:@""])
    {
        radius =textField.text.intValue;
        clipView.radius = radius;   //设置 裁剪框的半径  默认120
    }
    //    clipView.scaleRation = 5;// 图片缩放的最大倍数 默认为10
    [picker pushViewController:clipView animated:YES];
    
}

#pragma mark - ClipViewControllerDelegate
-(void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage
{
    UIImage *tempImage = [self creatImageWithMaskImage:[UIImage imageNamed:@"timg-3"] andBackimage:editImage];
    self.imageView.image = tempImage;
    [clipViewController dismissViewControllerAnimated:YES completion:^{
        
    }];;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [textField resignFirstResponder];
}


//--------------------------------------------------根据遮罩图形状裁剪
/**
 *  根据遮罩图片的形状，裁剪原图，并生成新的图片
 原图与遮罩图片宽高最好都是1：1。若比例不同，则会居中。
 若因比例问题达不到效果，可用下面的UIview转UIImage的方法，先制作1：1的UIview，然后转成UIImage使用此功能
 *
 *  @param MaskImage 遮罩图片：遮罩图片最好是要显示的区域为纯黑色，不显示的区域为透明色。
 *  @param Backimage 准备裁剪的图片
 *
 *  @return 新生成的图片
 */
- (UIImage *)creatImageWithMaskImage:(UIImage *)MaskImage andBackimage:(UIImage *)Backimage{
    
    CGRect rect;
    
    if (Backimage.size.height>Backimage.size.width) {
        rect     = CGRectMake(0,
                              (Backimage.size.height-Backimage.size.width),
                              Backimage.size.width*2,
                              Backimage.size.width*2);
    }else{
        rect     = CGRectMake((Backimage.size.width-Backimage.size.height),
                              0,
                              Backimage.size.height*2,
                              Backimage.size.height*2);
    }
    
    
    NSLog(@"%f",(Backimage.size.height-Backimage.size.height)/2);
    UIImage *cutIMG = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([Backimage CGImage], rect)];
    
    //遮罩图
    CGImageRef maskImage = MaskImage.CGImage;
    //原图
    CGImageRef originImage = cutIMG.CGImage;
    
    
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    // create a bitmap graphics context the size of the image
    
    mainViewContentContext = CGBitmapContextCreate (NULL,
                                                    rect.size.width,
                                                    rect.size.height,
                                                    8,
                                                    0,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast);
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    if (mainViewContentContext==NULL)
    {
        NSLog(@"error");
    }
    
    CGContextClipToMask(mainViewContentContext,
                        CGRectMake(0,
                                   0,
                                   rect.size.width,
                                   rect.size.height),
                        maskImage);
    
    CGContextDrawImage(mainViewContentContext,
                       CGRectMake(0,
                                  0,
                                  rect.size.width,
                                  rect.size.height),
                       originImage);
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(mainViewContentBitmapContext);
    
    
    
    
    return theImage;
    
}

- (void)pan:(UIPanGestureRecognizer * )pan{
    
    CGPoint transP = [pan translationInView:self.imageView];
    
    self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, transP.x, transP.y);
    
    [pan setTranslation:CGPointZero inView:self.imageView];
    
}

- (void)rotation:(UIRotationGestureRecognizer * )rotation{
    
    
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, rotation.rotation);
    
    rotation.rotation = 0;
    
}
- (void)pinch:(UIPinchGestureRecognizer * )pinch{
    
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, pinch.scale, pinch.scale);
    
    pinch.scale = 1;
    
}

//是否支持多个手势同时出发
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}

#pragma mark - getter

- (UIImageView *)imageView{
    if (!_imageView) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth / 4, screenHeight / 4 * 3, screenWidth / 4, screenWidth / 4)];
        tempImageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView = tempImageView;
    }
    return _imageView;
}

- (UIImageView *)txuImageView{
    if (!_txuImageView) {
        UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 330)];
        tempImageView.contentMode = UIViewContentModeScaleAspectFit;
        tempImageView.image = [UIImage imageNamed:@"0017030641567979_b"];
        _txuImageView = tempImageView;
    }
    return _txuImageView;
}

@end
