//
//  TetatestAppDelegate.h
//  Tetatest
//
//  Created by Seva on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "OpenGLView.h"
@interface TetatestAppDelegate : NSObject <UIApplicationDelegate> {
    OpenGLView* _glView;
    
   
}
// After @interface
@property (nonatomic, retain) IBOutlet OpenGLView *glView;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
