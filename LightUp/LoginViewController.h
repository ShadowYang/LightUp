//
//  LoginViewController.h
//  LightUp
//
//  Created by YangYuxin on 15/9/24.
//  Copyright © 2015年 Atlas19. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userPhoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPassWordTextField;

@end
