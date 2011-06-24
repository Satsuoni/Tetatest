//
//  SVTetrisBody.h
//  Tetatest
//
//  Created by Seva on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVScene.h"
#import "OpenGLView.h"
#import "Box2D.h"
#define MREC_POS 15
typedef struct
{
    float restitution;
    float density;
    float friction;
    BOOL isSensor;
    b2BodyType type;
    BOOL isBullet;
    
} b2Template;
@interface SVTetrisBody :NSObject {
@public
    unsigned int contactMode;
    NSMutableSet * touchingBodies;
     NSMutableSet * passingBodies;
    NSString *name;
    NSString *type;
    b2Body *body;
    b2World * world;
    CGPoint impulse;
    CGPoint recordedPositions[MREC_POS];
    int crec;
    int trec;
}
@property (nonatomic, readonly) NSMutableSet *touchingBodies;
@property (nonatomic, readonly) NSMutableSet *passingBodies;
- (unsigned int) getContactMode;
- (b2AABB) getAABB;
- (id) initWithRect: (CGRect) rect andTemplate:(b2Template) temp inWorld:(b2World *) world withName:(NSString *) name andType:(NSString * )type;
- (BOOL) canContactMode:(unsigned int) mode;
- (BOOL) canContact: (SVTetrisBody *) body;
- (void) setContactMode: (unsigned int) mode;
- (void) applyImpulse:(CGPoint) impulse;
- (void) addTouchingBody:(SVTetrisBody *) body;
- (BOOL) isSensor;
- (void) Reset;
- (NSString *) getName;
- (NSString *) getType;
- (void) setType: (NSString *) str;
- (void) updatePosition:(CGPoint) pos;
- (CGPoint) getPosition;
- (BOOL) isPresentonX:(int) x Y:(int) y withRect: (CGRect) ret;
- (CGRect) getBoundingBox;
- (BOOL) sleeps;
- (void) applyDirectImpulse: (CGPoint) impulse;
- (void) applyDirectVelocity: (CGPoint) vel;
- (void) Draw;
- (CGPoint) getVelocity;
- (void) applyLinearDamping:(float) damp;
- (void) recordPosition;
- (BOOL) checkOscillationatLevel:(float) level upToDiff:(float) diff;
- (void) destroyBody;
///////For derivative classes;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
@end