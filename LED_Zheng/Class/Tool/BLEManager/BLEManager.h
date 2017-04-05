//
//  BLEManager.h
//  FriedRice
//
//  Created by DFD on 2017/2/15.
//  Copyright © 2017年 DFD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEHeader.h"
#import "CBPeripheral+Additon.h"

#define DDBLE                      [BLEManager sharedManager]
#define DDSearchTime               10

// 蓝牙协议
@protocol BLEManagerDelegate <NSObject>  // 回调函数

@required

/**
 *  扫描到的设备字典
 */
- (void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt;

@optional

// ------------------------------------------------------- 蓝牙的系统回调

/**
 *  连接上设备的回调
 */
- (void)CallBack_ConnetedPeripheral:(NSString *)uuidString;


/**
 *  断开了设备的回调
 */
- (void)CallBack_DisconnetedPerpheral:(NSString *)uuidString;

/**
 *  写入成功的回调
 */
- (void)CallBack_WrotePerpheral:(NSString *)uuidString
                           uuid:(NSString *)uuid;

/**
 *  正在连接中
 */
- (void)CallBack_Connecting;


// ------------------------------------------------------- 根据业务的需要，自定义的回调

/**
 *  业务回调
 */
- (void)CallBack_Data:(BussinessCode)type
                  obj:(NSObject *)obj;

/**
 *  业务回调
 */
- (void)CallBack_ManageStateChange:(BOOL)isON;

@end

@protocol BLEManagerOTADelegate <NSObject>

@optional

// ota 发送已写入的数据长度，可用于做进度条
- (void)CallBack_OTAWriteLength:(NSInteger)length;

// ota 写入完毕，也有可能是中途出错退出，可通过判断 error 来得到结果
- (void)CallBack_OTAWriteFinishWithError:(NSError *)error;

@end


@interface BLEManager : NSObject

@property (nonatomic, weak) id<BLEManagerDelegate, BLEManagerOTADelegate>     delegate;

@property (nonatomic, strong) CBCentralManager *        manager;                // 中心设备实例

@property (nonatomic, strong) CBPeripheral *            per;                    // 当前连接对象

@property (nonatomic, assign) NSInteger                 connetNumber;           //  重连的次数

@property (nonatomic, strong) NSMutableDictionary *     dicFound;               // 发现的设备集合

@property (nonatomic, assign) NSInteger                 connetInterval;         //  重连的时间间隔 （单位：秒）

@property (nonatomic, assign) BOOL                      isFailToConnectAgain;   //  是否断开重连

@property (nonatomic ,assign) BOOL                      isOn;                   // 蓝牙是否开启

@property (nonatomic ,assign) BOOL                      isScaning;              // 蓝牙是否正在扫描

@property (nonatomic ,assign) BOOL                      isOK;                   // 通讯开始正常了

@property (nonatomic ,assign) ConnectState              connectState;           // 当前是否连接上  nonatomic





/**
 *  实例化 单例方法
 */
+ (BLEManager *)sharedManager;

/**
 *  重置所有状态
 */
+ (void)resetBLE;

/**
 *  开始扫描 （ 初始化中心设备，会导致已经连接的设备断开 ）
 */
- (void)startScan;

/**
 *  停止扫描
 */
- (void)stopScan;

/**
 *  连接设备
 */
- (void)connect:(NSString *)uuidString;

/**
 *  主动断开的设备。如果为nil，会断开所有已经连接的设备
 */
- (void)stopLink;


/**
 *  自动重连
 */
- (void)retrievePeripheral:(NSString *)uuidString;


/**
 握手
 */
- (void)handshake;


/**
 发送点阵数据

 @param textData 点阵数据的数组
 */
- (void)postTextData:(NSArray *)textData;


/**
 设置数据

 @param specialEffects 特效
 @param speed 速度
 @param residenceTime 停留时间
 @param border 边框
 @param viewStyle 显示类型
 @param logoData logo数据
 @param textData 点阵数据
 */
- (void)postTextData:(int)specialEffects
               speed:(int)speed
       residenceTime:(int)residenceTime
              border:(int)border
           viewStyle:(int)viewStyle
            logoData:(NSArray *)logoData
            textData:(NSArray *)textData;

@end

