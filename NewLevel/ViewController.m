//
//  ViewController.m
//  NewLevel
//
//  Created by Georg on 19.08.15.
//  Copyright (c) 2015 Georg. All rights reserved.
//

#import "ViewController.h"
#import "Bot.h"

static const CGFloat botHight = 0.074074074;
static const CGFloat botWidth = 0.1212121212;
static const CGFloat wallWidth = 0.36363636;
static const CGFloat wallHeight = 0.18181818;
//static const CGFloat fDestinationWidth = 0.272727;

@interface ViewController ()

@property (nonatomic, retain) NSTimer* wait;
@property (assign, nonatomic) NSInteger count;
@property (nonatomic, retain) NSTimer* botLvlSixTimer;
@property (assign, nonatomic) BOOL newComets;
@property (nonatomic, retain) NSTimer* sixtySeconds;
@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) BOOL playerDestruction;
@property (assign, nonatomic) NSInteger curse;
@property (nonatomic, retain) NSTimer* timerBot;
@property (nonatomic, retain) NSTimer* playerTimer;
@property (assign, nonatomic) BOOL touchStart;
@property (strong, nonatomic) UIView* monetkaView;
@property (strong, nonatomic) UIImageView* botView;
@property (strong, nonatomic) UIImageView* playerView;
@property (strong, nonatomic) UIImageView* movingView;
@property (assign, nonatomic) CGPoint touchCenterDifferance;
@property (assign, nonatomic) BOOL leftBotFlag;
@property (assign, nonatomic) CGRect* rect;
@property (strong, nonatomic) UIImageView* wallView;
@property (assign, nonatomic) CGPoint touchBeganPoint;
@property (strong, nonatomic) UIView* startView;
@property (strong, nonatomic) UIView* endView;
@property (strong, nonatomic) NSArray* bum;
@property (strong, nonatomic) NSArray* levels;
@property (strong, nonatomic) UILabel* labelNewLevel;
@property (strong, nonatomic) UIImageView* monetka;
@property (assign, nonatomic) BOOL monetkaTaken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.level = 4;
    self.monetkaTaken = NO;
    self.newComets = YES;
    self.count = 0;
    
    UIImageView* space = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:space];
    space.image = [UIImage imageNamed:@"space.png"];
    
    self.startView = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, 6, CGRectGetHeight(self.view.frame))];
    [self.view addSubview:self.startView];
    
    self.endView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 1, 0, 6, CGRectGetHeight(self.view.frame))];
    [self.view addSubview:self.endView];
    
    
    self.monetka = [[UIImageView alloc] initWithFrame:CGRectMake(arc4random() % (int)(self.view.frame.size.width - 60) + 30, arc4random() % (int)(self.view.frame.size.height - self.view.frame.size.height * 2 * wallHeight) + self.view.frame.size.height * wallHeight, 30, 40)];
    
    self.monetka.image = [UIImage imageNamed:@"alien on planet vector.png"];
    [self.view addSubview:self.monetka];
    
    [UIView animateWithDuration:10
                          delay:0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat |UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.monetka.transform = CGAffineTransformMakeRotation(3.14);
                     } completion:^(BOOL finished) {
                     }];
    self.botView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: self.botView];
    UILabel* labelNewLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    labelNewLevel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    labelNewLevel.textAlignment = NSTextAlignmentCenter;
    labelNewLevel.textColor = [UIColor whiteColor];
    labelNewLevel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    [self.view addSubview:labelNewLevel];
    labelNewLevel.text = [NSString stringWithFormat: @"Уровень %ld", (long)self.level];
    labelNewLevel.alpha = 0;
    self.labelNewLevel = labelNewLevel;
    
    self.playerDestruction = YES;
    [self levelArrays];
    [self start];
}

#pragma mark - start - restart - stop - pause

- (void) start {
    [self boomInitialisation];
    [self botInitialisation];
    [self playerInitiaisation];
    [self animationNewLevel];
    [self animateToBotStart];
    
    
    [self restart];
}

- (void)startTimerBot {
    if (self.level < 5) {
        self.timerBot = [NSTimer scheduledTimerWithTimeInterval:1.f/60
                                                         target:self
                                                       selector:@selector(animate)
                                                       userInfo:NULL
                                                        repeats:YES];

    } else {
        self.timerBot = [NSTimer scheduledTimerWithTimeInterval:1.f/20
                                                         target:self
                                                       selector:@selector(botGoesDown)
                                                       userInfo:NULL
                                                        repeats:YES];
    }
}

- (void) restart {
    [self playerStartCoordinates];
    [self animateToPlayerStart];
    self.playerDestruction = YES;
    self.view.userInteractionEnabled = YES;
    self.monetkaTaken = NO;
    self.monetka.alpha = 100;
}
- (void) restartLevelSix {
    self.playerDestruction = YES;
    self.view.userInteractionEnabled = YES;
    self.monetkaTaken = NO;
    self.monetka.alpha = 0;
    self.playerView.alpha = 1.f;
    
    [self playerLvlSixStart];
}

- (void) startLevelSix {
    [self startTimerBot];
    [self restartLevelSix];
    [self botInitPartTwo];
}

- (void) stop {
    [self.timerBot invalidate];
    [self.sixtySeconds invalidate];
  //  [self removeBot];
}

//- (void)removeBot {
//    [self.botView removeFromSuperview];
//}

- (void)stopBoomAnimation {
    [self.playerView stopAnimating];
    if (self.level < 5) {
        [self restart];
    } else {
        [self restartLevelSix];
    }
    
}

- (void) pause {
    
}

#pragma mark - initialisation
- (void) monetkaLocation {
    self.monetka.center = CGPointMake(arc4random() % (int)(self.view.frame.size.width - 60) + 30,
                                      arc4random() % (int)(self.view.frame.size.height - self.view.frame.size.height * 2 * wallHeight) + self.view.frame.size.height * wallHeight);
}

- (void) botInitialisation {
    for (int hight = 0; hight <= 4; hight++) {
        if (!(hight % 2)) {
            Bot* bot = [[Bot alloc] initWithFrame:  CGRectMake(CGRectGetWidth(self.view.frame) * (0.90909090 - 0.09090909),
                                                               CGRectGetHeight(self.view.frame) * wallHeight + CGRectGetHeight(self.view.frame) * (0.1111111111 * hight),
                                                               CGRectGetWidth(self.view.frame) * botWidth,
                                                               CGRectGetHeight(self.view.frame) * botHight)];
            [self.botView addSubview:bot];
            bot.image = [UIImage imageNamed:@"комета png.png"];
            bot.animationDuration = 1.f;
            bot.leftSide = YES;
            [bot startAnimating];
        } else {
            Bot* bot = [[Bot alloc] initWithFrame:CGRectMake(0,
                                                             CGRectGetHeight(self.view.frame) * wallHeight + CGRectGetHeight(self.view.frame) * (0.1111111111 * hight),
                                                             CGRectGetWidth(self.view.frame) * botWidth,
                                                             CGRectGetHeight(self.view.frame) * botHight)];
            [self.botView addSubview:bot];
            bot.image = [UIImage imageNamed:@"комета png.png"];
            bot.animationDuration = 1.f;
            bot.leftSide = NO;
            [bot startAnimating];
        }
    }
}

- (void)playerInitPartTwo {
    self.playerView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 0.75);
}

- (void)botInitPartTwo {
    for (Bot*bot in self.botView.subviews) {
        bot.center = CGPointMake(arc4random() % ((int)self.view.frame.size.width - 40) + 20, -(arc4random() % 300 - 100));
    }
    
//    while (self.count != 25) {
//        [self startTimerBot];
//    }
}

- (void)time {
    self.sixtySeconds = [NSTimer scheduledTimerWithTimeInterval:15/10.f
                                                         target:self
                                                       selector:@selector(botGoesDown)
                                                       userInfo:NULL
                                                        repeats:NO];
}

- (void)waitNextWave {
    self.wait = [NSTimer scheduledTimerWithTimeInterval:3.f
                                                 target:self
                                               selector:@selector(botGoesDown)
                                               userInfo:NULL
                                                repeats:NO];

}

- (void)playerLvlSixStart {
    self.playerView.center = CGPointMake(self.view.frame.size.width / 4, self.view.frame.size.height * 0.6);
    self.playerView.alpha = 1.f;
    
}

- (void)botLvlSixStart {
    for (Bot* bot in self.botView.subviews) {
        bot.center = CGPointMake(arc4random() % ((int)self.view.frame.size.width - 40) + 20, -arc4random() % 300);
    }
}

- (void)botStartCoordinates {
    for (Bot* bot in self.botView.subviews) {
        if ([self.botView.subviews indexOfObject:bot] % 2) {
            bot.center = CGPointMake(self.view.frame.size.width - self.view.frame.size.width * botWidth,
                                     self.view.frame.size.height * wallHeight + self.view.frame.size.height * (0.1111111111 * [self.botView.subviews indexOfObject:bot]) + bot.frame.size.height / 2);
        } else {
            bot.center = CGPointMake(self.view.frame.size.width * botWidth,
                                     self.view.frame.size.height * wallHeight + self.view.frame.size.height * (0.1111111111 * [self.botView.subviews indexOfObject:bot]) + bot.frame.size.height / 2);
        }
    }
}

- (void)animateToBotStart {
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self botStartCoordinates];
                     } completion:^(BOOL finished) {
                         [self startTimerBot];
                     }];
}



- (void) playerInitiaisation {
    UIImageView* player = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * wallWidth, 0,
                                                                        CGRectGetWidth(self.view.frame) * 0.25,
                                                                        CGRectGetHeight(self.view.frame) * 0.0888888)];
    
    player.image = [UIImage imageNamed:@"bobTheAlien.png"];
    
    [self.view addSubview:player];
    self.playerView = player;
    self.playerView.animationImages = self.bum;
}

- (void)playerStartCoordinates {
    self.playerView.center = CGPointMake(self.view.frame.size.width / 2, -CGRectGetHeight(self.view.frame) * 0.0888888);
}

- (void)animateToPlayerStart {
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                         self.playerView.center = CGPointMake(self.view.frame.size.width / 2, CGRectGetHeight(self.view.frame) * 0.0888888);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)boomInitialisation {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 18; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d%@", @"bang", i, @".png"]];
        [images addObject:img];
    }
    
    self.bum = images;
}


#pragma mark - level

- (void) levelArrays {
    NSArray* level1 =  @[@3, @3, @5, @3, @3];
    NSArray* level2 =  @[@3, @5, @5, @5, @3];
    NSArray* level3 =  @[@6, @5, @5, @5, @6];
    NSArray* level4 =  @[@4, @4, @5, @4, @4];
    NSArray* level5 =  @[@1, @1, @1, @1, @1];

   self.levels = @[level1, level2, level3, level4, level5];
}

- (void) animationNewLevel {
    self.labelNewLevel.text = [NSString stringWithFormat: @"Уровень %ld", (long)self.level + 1];
    
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.labelNewLevel.alpha = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.labelNewLevel.alpha = 0;
                                          } completion:^(BOOL finished) {
                                          }];
                     }];
}

#pragma mark - animation

- (void) animate {
    
    for (Bot* bot in self.botView.subviews) {
        self.curse = [[[self.levels objectAtIndex:self.level] objectAtIndex:[self.botView.subviews indexOfObject:bot]] integerValue];
        if (CGRectIntersectsRect(bot.frame, self.endView.frame)) {
            bot.leftSide = YES;
        } else if (CGRectIntersectsRect(bot.frame, self.startView.frame)){
            bot.leftSide = NO;
        }

        if (bot.leftSide == YES) {
                self.curse = self.curse * (-1);
        }
        [self rotation:bot];
        bot.center = (CGPointMake(bot.center.x + self.curse, bot.center.y));
        
        if (self.playerDestruction == YES) {
            [self intersection:bot];
        }
    }
}

- (void) botGoesDown {
    
    for (Bot* bot in self.botView.subviews) {
//        if (bot == [self.botView.subviews objectAtIndex: 2]) {
//            self.count++;
//            [self time];
//        }
        if (bot.center.y > self.view.frame.size.height + 40) {
            bot.center = CGPointMake(arc4random() % ((int)self.view.frame.size.width - 40) + 20, -(arc4random() % 300 - 100));
//            if (bot == [self.botView.subviews objectAtIndex: 2]) {
//                self.count++;
//                [self time];
//            }
            self.count++;
            [self time];
        } else {
            bot.center = CGPointMake(bot.center.x, bot.center.y + 6);
        }
        [self intersection:bot];
    }
}

- (void) rotation: (Bot*) bot {
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransformRotate(self.botView.transform, 360);
                         //self.botView.transform = CGAffineTransformMakeRotation(360);
                     } completion:^(BOOL finished) {
                     }];
}

- (void) intersection: (Bot*) bot {
    if (CGRectIntersectsRect(self.playerView.frame, bot.frame)) {
        self.view.userInteractionEnabled = NO;
        [self.timerBot invalidate];
        if (self.level < 5) {
            [self animateToBotStart];
        } else {
            [self restartLevelSix];
        }
        self.playerView.animationImages = self.bum;
        self.playerView.animationDuration = 0.7;
        [self.playerView startAnimating];
        self.playerDestruction = NO;
        self.touchStart = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.7
                                         target:self
                                       selector:@selector(stopBoomAnimation)
                                       userInfo:NULL
                                        repeats:NO];
        
    }
    if (CGRectIntersectsRect(self.playerView.frame, self.monetka.frame)) {
        self.monetka.alpha = 0;
        self.monetkaTaken = YES;
        
    }
}

- (void)animatePlayer:(CGPoint)point {
    if (self.touchStart == YES) {
        self.playerView.center = CGPointMake(point.x, point.y);
        if (self.playerView.center.x < self.view.frame.size.width * botWidth) {
            self.playerView.center = CGPointMake(self.playerView.frame.size.width / 2, point.y);
        } else if (self.playerView.center.x > (self.view.frame.size.width - self.playerView.frame.size.width / 2)) {
            self.playerView.center = CGPointMake(self.view.frame.size.width - self.playerView.frame.size.width / 2, point.y);
        }
        if (self.playerView.frame.origin.y < 0.0001) {
            self.playerView.center = CGPointMake(point.x, 0.0001 + self.playerView.frame.size.height / 2);
        }
    }
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchStart = YES;
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.playerView];
    self.touchCenterDifferance = CGPointMake(CGRectGetMidX(self.playerView.bounds) - touchPoint.x,
                                             CGRectGetMidY(self.playerView.bounds) - touchPoint.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
       if (self.touchStart == YES) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        CGPoint correction = CGPointMake(pointOnMainView.x + self.touchCenterDifferance.x,
                                         pointOnMainView.y + self.touchCenterDifferance.y);
        [self animatePlayer:correction];
        
        if (self.playerView.center.y > self.view.frame.size.height * 0.7 && self.monetkaTaken == YES) {
            self.touchStart = NO;
            [self.timerBot invalidate];
            
            [self animateToBotStart];
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:1
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.playerView.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
                             } completion:^(BOOL finished) {
                                 self.level++;
                                 [self monetkaLocation];
                                 if (self.level > 4) {
                                     [self stop];
                                     [self startLevelSix];

                                 } else {
                                     [self animationNewLevel];
                                     [self restart];
                                 }
                             }];

        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchStart = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchStart = NO;
}

@end