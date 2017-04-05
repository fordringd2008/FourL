//
//  FRSearchDeviceController.m
//  FriedRice
//
//  Created by DFD on 2017/2/15.
//  Copyright © 2017年 DFD. All rights reserved.
//

#import "FRSearchDeviceController.h"

#import "FRSearchDeviceCell.h"

static NSString * const cellId = @"FRSearchDeviceCell";


typedef NS_ENUM(NSUInteger, ViewState) {
    ViewState_BleOff = 0,               // 蓝牙关闭
    ViewState_SearchIng,                // 正在搜索
    ViewState_NOFound,                  // 没有发现
    ViewState_Select,                   // 选择设备
    ViewState_Connecting                // 正在连接
};

@interface FRSearchDeviceController (){
    NSDate *beginDate;
    BOOL swtRefresh;                            // 刷新开关
    NSTimer *timer;
    CBPeripheral *cbp;                          // 记录点击的设备UUIDString
    BOOL isRegister;                            // 时候是注册跳进来的
    
}

@property (strong, nonatomic) NSMutableDictionary *          dicData;           // 数据源
@property (weak, nonatomic) IBOutlet UILabel *              promptLabel;
@property (weak, nonatomic) IBOutlet UIView *               containerView;      // 放 菊花 的容器
@property (weak, nonatomic) IBOutlet UIView *               container2View;     // 放 tableView 的容器
@property (weak, nonatomic) IBOutlet UILabel *              promptBottonLabel;
@property (weak, nonatomic) IBOutlet UIImageView *          middleImageView;
@property (weak, nonatomic) IBOutlet UIButton *tryButton;



@property (nonatomic, assign) ViewState                     viewState;          // 当前的界面状态

@end

@implementation FRSearchDeviceController

- (instancetype)initWithRegister{
    if (self = [super init]) {
        isRegister = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkLink) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    timer = nil;
    DDBLE.delegate = nil;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


- (void)setuFont{
    
}

- (void)setUI{
    [super setUI];
    
    // 设置菊花
    CGFloat width = RealWidth(380);
//    self.loadingView = [[SkyLabelWaitingView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
//    self.loadingView.ringColor = DTipsButtonSwithBackgroundColor;
//    self.loadingView.ringWidth = 5.f;
//    self.loadingView.r = (self.loadingView.bounds.size.height - self.loadingView.ringWidth ) / 2 ;
//    [self.containerView insertSubview:self.loadingView belowSubview:self.middleImageView];
//    [self.loadingView start];
    
    if (!self.tabView) {
        self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, RealWidth(611), 180) style:UITableViewStylePlain];
        self.tabView.delegate = self;
        self.tabView.dataSource = self;
        self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tabView.backgroundColor = DBackgroundColor;
        [self.container2View addSubview:self.tabView];
        [self.tabView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
    }
    
//    [self.tryButton setBackgroundImage:[UIImage imageFromColor:DNormalColor] forState:UIControlStateNormal];
//    [self.tryButton setBackgroundImage:[UIImage imageFromColor:DHighLightColor] forState:UIControlStateHighlighted];
    
    
    self.tryButton.layer.cornerRadius = 5;
    self.tryButton.layer.masksToBounds = YES;
    self.tryButton.hidden = YES;
    [self.tryButton setTitle:kString(@"Try again") forState:UIControlStateNormal];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    [leftBtn setTitle:kString(@"返回") forState:UIControlStateNormal];
    [leftBtn addTarget:self
                action:@selector(barbuttonItemLeftClick)
      forControlEvents:UIControlEventTouchUpInside];
    self.navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    [self beginSearchAgain];
}

- (void)setupDisconnectTipsView{
    // 重写父类
}


- (void)barbuttonItemLeftClick{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:NULL];
    });
}


- (void)barbuttonItemRightClick{
    
    [self postBigData];
    
}

- (IBAction)postBigData {
    
    // NSArray *arrData = [GlobalTool getPlayerJsonByJsonName:@"subtitle4.json"];
    // [DDBLE sendVideoBuffer:arrData lenth:4];
    
//    NSArray *arrData = [GlobalTool getPlayerJsonByJsonName:@"subtitle_defaultMode3.json"];
////    [DDBLE sendVideoBuffer:arrData lenth:3];
//    
//    [DDBLE sendDefaultModel:1 identificationCode:4 defaultModelArray:arrData lenth:3];
}

- (void)getUserList{
    
//    NSString *str = @"K7148722499475011702100013,Y1148714308587511702300007";
//    
//    [DFDN getUserListBySSIDs:str
//                  completion:^(NSArray * _Nonnull array) {
//       
//               NSLog(@"%@", array);
//        
//    }];
    
}


-(void)beginSearchAgain{
    if (!DDBLE.isOn) {
        self.viewState = ViewState_BleOff;
        return;
    }
    
    self.viewState = ViewState_SearchIng;
    beginDate = [NSDate date];
    
    [DDBLE startScan];
    
    [self.dicData removeAllObjects];
    [self.tabView reloadData];
    
    DDWeakVV
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DDStrongVV
        if(self.dicData.count){
            self.tabView.userInteractionEnabled = YES;
        }
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DDSearchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DDStrongVV
        if(!self.dicData.count){
            if (self.view.window) {
                if (DDBLE.isOn) {
                    self.viewState = ViewState_NOFound;
                }
            }
        }
    });
}

- (void)checkisLinkAfterConnecting{
    if (DDBLE.connectState != ConnectState_Connected) {
        MBHide
        MBShow(@"请尝试重新连接");
        swtRefresh = NO;
        [self beginSearchAgain];
    }
}


- (void)checkLink{
    if (DDBLE.connectState == ConnectState_Connected){
        [timer invalidate];
        timer = nil;
    }
}


- (void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt{
    if(!swtRefresh){
        
        DDWeakVV
        dispatch_async(dispatch_get_main_queue(), ^{
            DDStrongVV
            
            self.dicData = [recivedTxt mutableCopy];
            if (self.dicData.count > 0 && [[NSDate date] timeIntervalSinceDate:beginDate] > 1.5){
                self.tabView.userInteractionEnabled = YES;
                NSLog(@"刷新界面");
                if (self.viewState != ViewState_Select) {
                    self.viewState = ViewState_Select;
                }
                
                beginDate = [NSDate date];
                [self.tabView reloadData];
            }
        });
    }
}

- (void)CallBack_ConnetedPeripheral:(NSString *)uuidString{
    
    NSLog(@"连接成功了");
}

- (void)CallBack_ManageStateChange:(BOOL)isON {
    NSLog(@"当前蓝牙开关状态:%@", @(isON));
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isON) {
            [self beginSearchAgain];
        }else{
            self.viewState = ViewState_BleOff;
        }
    });
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return self.dicData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FRSearchDeviceCell *cell = [FRSearchDeviceCell cellWithTableView:tableView];
    cell.device = (CBPeripheral *)self.dicData.allValues[indexPath.row];    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [DDBLE stopScan];
    
    FRSearchDeviceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cbp = cell.device;
    
    swtRefresh = YES;
    
    self.viewState = ViewState_Connecting;
    [DDBLE retrievePeripheral:cbp.identifier.UUIDString];
    MBShow(@"Linking..");
    
    [self performSelector:@selector(checkisLinkAfterConnecting) withObject:nil afterDelay:10];
    // 这里防止用户点击后， 连接不上， 是因为设备已经长时间没有连接停止广播造成的
    beginDate = [NSDate date];
    [self.tabView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tryButtonClick {
    [self beginSearchAgain];
    self.viewState = ViewState_SearchIng;
}


- (void)setViewState:(ViewState)viewState{
    _viewState = viewState;
    
    _tryButton.hidden = YES;
    _container2View.hidden = YES;
    
    switch (viewState) {
        case ViewState_BleOff:
            _promptLabel.text = kString(@"Bluetooth is off");
            _promptBottonLabel.text = kString(@"Please turn on Bluetooth in settings");
            break;
        case ViewState_SearchIng:
            _promptLabel.text = kString(@"Searching...");
            _promptBottonLabel.text = kString(@"Power on the device by pressing the bottom on the bottom for 3 sec.");
            break;
        case ViewState_NOFound:
            _promptLabel.text = kString(@"No device available");
            _promptBottonLabel.text = @"";
            _tryButton.hidden = NO;
            break;
        case ViewState_Select:
            _promptLabel.text = kString(@"Devices");
            _promptBottonLabel.text = @"";
            _container2View.hidden = NO;
            break;
        case ViewState_Connecting:{
            NSString *text = [NSString stringWithFormat:@"Your %@ is connecting", cbp.isAris ? @"Aris":@"Ishtar"];
            _promptLabel.text = kString(text);
        }
            break;
    }
    [_promptLabel sizeToFit];
    [_promptBottonLabel sizeToFit];
}
- (IBAction)backClick {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end