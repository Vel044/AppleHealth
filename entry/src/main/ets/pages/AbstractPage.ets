// pages/AbstractPage.ets
import { Health,HealthDataStore } from "../model/Health"
import { UserInfo, defaultUserInfo } from '../model/UserInfo';
import geoLocationManager from '@ohos.geoLocationManager';
import sensor from '@ohos.sensor';
import StepsUtil from '../common/utils/StepsUtil';
import { CommonConstants } from '../common/constants/CommonConstants';
import NumberUtil from '../common/utils/NumberUtil';
import Logger from '../common/utils/Logger';
import LocationUtil from '../common/utils/LocationUtil';
import { GlobalHealthData } from "../model/Healthy";
import router from '@ohos.router'
import Intl from '@ohos.intl';
import { AppStorageV2 } from "@kit.ArkUI"
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

// 添加PersistentStorage初始化
PersistentStorage.persistProp('todaySteps', 624);
PersistentStorage.persistProp('todayActiveEnergy', 10.2);
PersistentStorage.persistProp('todayHeight', 173);
PersistentStorage.persistProp('todayWeight', 65.5);
PersistentStorage.persistProp('todayBMI', 21.8);
PersistentStorage.persistProp('todayFlightsClimbed', 8);

const TAG: string = 'AbstractPage';




// const permissions: Array<Permissions> = ['ohos.permission.ACTIVITY_MOTION'];
// // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
// function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
//   let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
//   // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
//   atManager.requestPermissionsFromUser(context, permissions).then((data) => {
//     let grantStatus: Array<number> = data.authResults;
//     let length: number = grantStatus.length;
//     for (let i = 0; i < length; i++) {
//       if (grantStatus[i] === 0) {
//         // 用户授权，可以继续访问目标操作
//         console.log("123456允许")
//       } else {
//         // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
//         console.log("123456拒绝")
//         return;
//       }
//     }
//     // 授权成功
//   }).catch((err: BusinessError) => {
//     console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
//   })
// }


@Entry
@Component
export default struct AbstractPage {
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? defaultUserInfo;
  @StorageLink('currentBMI') tempBMI: number = 0;
  date:Date=new Date();

  healthDataStore: HealthDataStore = HealthDataStore.getInstance();
  @StorageLink('healthHistory') healthHistory :Health[]=this.healthDataStore.healthHistory

  @StorageLink('todayHealth') todayHealth:Health= AppStorage.get('todayHealth') ?? this.healthHistory[6];

  // 添加六个健康数据的StorageLink
  @StorageLink('todaySteps') todaySteps: number = 624;
  @StorageLink('todayActiveEnergy') todayActiveEnergy: number = 10.2;
  @StorageLink('todayHeight') todayHeight: number = 173;
  @StorageLink('todayWeight') todayWeight: number = 65.5;
  @StorageLink('todayBMI') todayBMI: number = 21.8;
  @StorageLink('todayFlightsClimbed') todayFlightsClimbed: number = 8;

  healthData:GlobalHealthData = AppStorageV2.connect(GlobalHealthData,'HEALTH_KEY',()=>new GlobalHealthData())!


  // 添加动态背景相关状态变量
  @State gradientAngle: number = 0;
  @State gradientOffset1: number = 0;
  @State gradientOffset2: number = 0.3;
  @State gradientOffset3: number = 0.6;
  @State gradientOffset4: number = 0.9;

  @State currentSteps: string = CommonConstants.INITIALIZATION_VALUE;
  @Provide stepGoal: string = '';
  @State oldSteps: string = '';
  @State startPosition: string = '';
  @State currentLocation: string = '';
  @State locale: string = new Intl.Locale().language;
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State progressValue: number = 0;
  @State isStart: boolean = true;

  //上下文
  @State context: common.UIAbilityContext | null = null



  aboutToAppear(): void {
    // 计算BMI值
    this.calculateBMI();
    // 同步用户信息到健康数据
    if (this.userInfo && this.userInfo.userHeight > 0 && this.userInfo.weight > 0) {
      this.todayHealth.height = this.userInfo.userHeight;
      this.todayWeight = this.userInfo.userHeight;
      this.todayHealth.weight = this.userInfo.weight;
      this.todayWeight = this.userInfo.weight;
      this.todayHealth.bmi = this.tempBMI;
      this.todayBMI = this.tempBMI;
    }
    this.healthData.startStepCounter()
    // 从todayHealth同步数据到独立存储
    this.todaySteps = this.todayHealth.steps;
    this.todayActiveEnergy = this.todayHealth.activeEnergy;
    this.todayHeight = this.todayHealth.height;
    this.todayWeight = this.todayHealth.weight;
    this.todayBMI = this.todayHealth.bmi;
    this.todayFlightsClimbed = this.todayHealth.flightsClimbed;

    // 初始化步数并请求权限、
    StepsUtil.putStorageValue(CommonConstants.IS_START, CommonConstants.TRUE);
    this.init();
    this.requestPermissions();
        
      
    // 启动背景动画
    this.startBackgroundAnimation();

    // 获取上下文，用于请求权限
    this.context = getContext(this) as common.UIAbilityContext;

    // 启动步数计数器
    this.healthData.startStepCounter();
  }



  // 添加背景动画方法
  startBackgroundAnimation() {
    // 渐变角度动画
    animateTo({
      duration: 10000,
      tempo: 1.0,
      curve: Curve.Linear,
      iterations: -1, // 无限循环
      playMode: PlayMode.Normal
    }, () => {
      this.gradientAngle = (this.gradientAngle + 360) % 360;
    })
    
    // 渐变位置动画
    animateTo({
      duration: 8000,
      tempo: 1.0,
      curve: Curve.Ease,
      iterations: -1,
      playMode: PlayMode.Alternate
    }, () => {
      this.gradientOffset1 = (this.gradientOffset1 + 0.5) % 1;
      this.gradientOffset2 = (this.gradientOffset2 + 0.5) % 1;
      this.gradientOffset3 = (this.gradientOffset3 + 0.5) % 1;
      this.gradientOffset4 = (this.gradientOffset4 + 0.5) % 1;
    })
  }




  aboutToDisappear() {
    // 关闭传感器监听
    sensor.off(sensor.SensorId.PEDOMETER);
  }


  onPageShow() {
    this.init();
    this.requestPermissions();
    this.healthData.startStepCounter()
  }

  init() {
    this.isStart = true;
    StepsUtil.getStorageValue(CommonConstants.CURRENT_STEPS).then((res: string) => {
      if (StepsUtil.checkStrIsEmpty(res)) {
        return;
      }
      this.currentSteps = res;
    });

    StepsUtil.getStorageValue(CommonConstants.PROGRESS_VALUE_TAG).then((res: string) => {
      if (StepsUtil.checkStrIsEmpty(res)) {
        return;
      }
      this.progressValue = NumberUtil._parseInt(res, 10);
    });

    StepsUtil.getStorageValue(CommonConstants.START_POSITION).then((res: string) => {
      if (StepsUtil.checkStrIsEmpty(res)) {
        return;
      }
      this.startPosition = res;
    });

    StepsUtil.getStorageValue(CommonConstants.OLD_STEPS).then((res: string) => {
      if (StepsUtil.checkStrIsEmpty(res)) {
        return;
      }
      this.oldSteps = res;
    });

    StepsUtil.getStorageValue(CommonConstants.STEP_GOAL).then((res: string) => {
      if (StepsUtil.checkStrIsEmpty(res)) {
        return;
      }
      this.stepGoal = res;
    });
  }

  requestPermissions(): void {
    let atManager = abilityAccessCtrl.createAtManager();
     try {
      atManager.requestPermissionsFromUser(this.context, CommonConstants.REQUEST_PERMISSIONS).then((data) => {
        if (data.authResults[0] !== 0 || data.authResults[1] !== 0) {
          return;
        }
        const that = this;
        try {
          sensor.on(sensor.SensorId.PEDOMETER, (data) => {
            try {
              if (that.isStart) {
                if (StepsUtil.checkStrIsEmpty(that.oldSteps)) {
                  that.oldSteps = data.steps.toString();
                  StepsUtil.putStorageValue(CommonConstants.OLD_STEPS, that.oldSteps);
                } else {
                  that.currentSteps = (data.steps - NumberUtil._parseInt(that.oldSteps, 10)).toString();
                }
              } else {
                that.currentSteps = data.steps.toString();
              }

              if (StepsUtil.checkStrIsEmpty(that.stepGoal) || !that.isStart) {
                return;
              }
              StepsUtil.putStorageValue(CommonConstants.CURRENT_STEPS, that.currentSteps);
              that.progressValue = StepsUtil.getProgressValue(NumberUtil._parseInt(that.stepGoal, 10),
                NumberUtil._parseInt(that.currentSteps, 10));
              StepsUtil.putStorageValue(CommonConstants.PROGRESS_VALUE_TAG, String(that.progressValue));
            } catch (err) {
              Logger.error(TAG, 'Sensor on err' + JSON.stringify(err));
            }
          }, { interval: CommonConstants.SENSOR_INTERVAL });

        } catch (err) {
          console.error('On fail, errCode: ' + JSON.stringify(err));
        }

        LocationUtil.geolocationOn((location: geoLocationManager.Location) => {
          if (this.latitude === location.latitude && this.longitude === location.longitude) {
            return;
          }
          this.latitude = location.latitude;
          this.longitude = location.longitude;
          let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
            'locale': this.locale.toString().includes('zh') ? 'zh' : 'en',
            'latitude': this.latitude,
            'longitude': this.longitude
          };
          geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest).then(data => {
            if (data[0].placeName) {
              this.currentLocation = data[0].placeName;
            }
          }).catch((err: Error) => {
            Logger.error(TAG, 'GetAddressesFromLocation err ' + JSON.stringify(err));
          });
        });
      }).catch((err: Error) => {
        Logger.error(TAG, 'requestPermissionsFromUser err' + JSON.stringify(err));
      })
    } catch (err) {
      Logger.error(TAG, 'requestPermissionsFromUser err' + JSON.stringify(err));
    }
  }


  calculateBMI(): void {
    if (this.userInfo && this.userInfo.userHeight > 0 && this.userInfo.weight > 0) {
      this.tempBMI = Math.round((this.userInfo.weight / (this.userInfo.userHeight * this.userInfo.userHeight / 10000)) * 10) / 10;
    }
  }



  private calculateHealthPercentage(healthParam: string, dayIndex: number,healthHistory:Health[]): string {

    if (!healthHistory || healthHistory.length === 0) {
      return "0%";
    }

    const index = Math.min(Math.max(dayIndex, 0), healthHistory.length - 1);
    // const record = healthHistory[index];

    let minValue = Number.MAX_VALUE;
    let maxValue = Number.MIN_VALUE;
    let currentValue = 0;

    for (let i = 0; i < healthHistory.length; i++) {
      let value: number;
      switch (healthParam) {
        case 'steps':
          value = healthHistory[i].steps;
          break;
        case 'activeEnergy':
          value = healthHistory[i].activeEnergy;
          break;
        case 'flightsClimbed':
          value = healthHistory[i].flightsClimbed;
          break;
        case 'heartRate':
          value = healthHistory[i].heartRate;
          break;
        case 'sleepAnalysis':
          value = healthHistory[i].sleepAnalysis;
          break;
        case 'bloodOxygen':
          value = healthHistory[i].bloodOxygen;
          break;
        case 'bodyTemperature':
          value = healthHistory[i].bodyTemperature;
          break;
        case 'stressLevel':
          value = healthHistory[i].stressLevel;
          break;
        case 'bmi':
          value = healthHistory[i].bmi;
          break;
        case 'height':
          value = healthHistory[i].height;
          break;
        case 'weight':
          value = healthHistory[i].weight;
          break;
        default:
          value = 0;
      }

      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
      if (i === index) currentValue = value;
    }

    if (maxValue === minValue) {
      return "100%";
    }



    const percentage = ((currentValue - minValue) / (maxValue - minValue)) * 100;
    return `${Math.max(10, Math.min(100, percentage))}%`;
  }



  // 柱状图Builder函数
  @Builder
  private HistogramChart(healthParam: string) {
    Row() {
      ForEach([0, 1, 2, 3, 4, 5, 6], (dayIndex: number) => {
        Column() {
          Column()
            .width(10)
            .height(this.calculateHealthPercentage(healthParam, dayIndex,this.healthHistory))
            .backgroundColor(dayIndex==6 ? "#419cff" : "#999999")
            .borderRadius(6)
        }
        .width(16)
        .height(60)
        .justifyContent(FlexAlign.End)
        .margin({ right: dayIndex < 6 ? 2 : 0 })
      })
    }
    .margin(10)
    .width(120)
    .height("100%")
    .justifyContent(FlexAlign.SpaceEvenly)
  }


  @Builder
  private fitnessTemplate(fitness:string,data:number,unit:string){
    Column(){
      Row(){
        Row(){
          Image($r("app.media.fire"))
            .height(20)
            .margin(5)
            .colorBlend(Color.Red)
          Text(fitness)
            .fontSize(16)
            .fontColor(Color.Red)
        }.margin(5)
        Row(){
          Text(this.date.getHours()+":"+(this.date.getMinutes()<10?"0":"") + this.date.getMinutes())  //防止出现19：9而非19：09的情况
            .fontSize(12)
            .fontColor(Color.Gray)
          Image($r("app.media.right_click"))
            .height(20)
            .margin(5)
            .colorBlend(Color.Gray)
        }

      }.justifyContent(FlexAlign.SpaceBetween)
      .width("100%")
      Row(){
        Column(){
          Row(){
            Text(data + "")
              .fontSize(30)
              .alignSelf(ItemAlign.End)
              .fontWeight(FontWeight.Bold)
            Text(unit)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Gray)
              .alignSelf(ItemAlign.End)
              .margin(5)

          }.alignSelf(ItemAlign.End)
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Bottom)

        }
        .alignSelf(ItemAlign.End)
        .margin({ left:15,bottom:5 })

        if (fitness === "步数") {
          this.HistogramChart("steps");
        } else if (fitness === "活动能量") {
          this.HistogramChart("activeEnergy");
        } else if (fitness === "已爬楼层") {
          this.HistogramChart("flightsClimbed");
        }


      }.width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .height(80)


    }.borderRadius(10)
    .backgroundColor(Color.White)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top:5,bottom:5 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: {
          type: fitness,
          data: data,
          unit: unit
        }
      });
    })

  }
 
  @Builder
  private bodyTemplate(fitness: string , $$: number , unit: string) {
    Column(){
      Row(){
        Row(){
          Image($r("app.media.people"))
            .height(20)
            .margin(5)
            .colorBlend(Color.Blue)
          Text(fitness)
            .fontSize(16)
            .fontColor(Color.Blue)
        }.margin(5)
        Row(){
          Text(this.date.getHours()+":"+(this.date.getMinutes()<10?"0":"") + this.date.getMinutes())  //防止出现19：9而非19：09的情况
            .fontSize(12)
            .fontColor(Color.Gray)
          Image($r("app.media.right_click"))
            .height(20)
            .margin(5)
            .colorBlend(Color.Gray)
        }

      }.justifyContent(FlexAlign.SpaceBetween)
      .width("100%")
      Row(){
        Column(){
          Text("平均")
            .fontSize(16)
            .fontColor(Color.Gray)
            .alignSelf(ItemAlign.Start)

          Row(){
            if(fitness=="身高体重指数") {
              Text(this.tempBMI.toString())
                .fontSize(30)
                .alignSelf(ItemAlign.End)
                .fontWeight(FontWeight.Bold)
            }else if(fitness=="身高") {
              Text(this.todayHeight.toString())
                .fontSize(30)
                .alignSelf(ItemAlign.End)
                .fontWeight(FontWeight.Bold)
            }else if(fitness=="体重"){
              Text(this.todayWeight.toString())
                .fontSize(30)
                .alignSelf(ItemAlign.End)
                .fontWeight(FontWeight.Bold)
            }

              Text(unit)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Gray)
              .alignSelf(ItemAlign.End)
              .margin(5)

          }.alignSelf(ItemAlign.End)
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Bottom)

        }
        .alignSelf(ItemAlign.End)
        .margin({ left:15,bottom:5 })


        
        // ... existing code ...
        // 替换为柱状图
        if (fitness === "身高") {
          this.HistogramChart("height");
        } else if (fitness === "体重") {
          this.HistogramChart("weight");
        } else if (fitness === "身高体重指数") {
          this.HistogramChart("bmi");
        }


      }.width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .height(80)


    }.borderRadius(10)
    .backgroundColor(Color.White)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top:5,bottom:5 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: {
          type: fitness,
          data: $$,
          unit: unit
        }
      });
    })
  }


  build() {
    Stack() {
      List(){
        // 摘要
        ListItem()
        {
          Row(){
            Text("摘要")
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
            Image($r("app.media.profile"))
              .height(35)
              .borderRadius(35)
          }.justifyContent(FlexAlign.SpaceBetween)
          .width("100%")
          .margin({bottom:20,top:20})
        }
        // 置顶
        ListItem(){
          Row(){
            Text("置顶")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            Text("编辑")
              .fontSize(18)
              .fontColor("#007AFF")
          }.justifyContent(FlexAlign.SpaceBetween)
          .width("100%")
        }
        // 置顶数据
        ListItem(){
          Column(){
            this.fitnessTemplate("步数", this.todaySteps, "步")
            this.fitnessTemplate("活动能量", this.todayActiveEnergy, "千卡")
            this.bodyTemplate("身高", this.todayHeight, "cm")
            this.bodyTemplate("体重", this.todayWeight, "kg")
            this.bodyTemplate("身高体重指数", this.tempBMI, "BMI")
            this.fitnessTemplate("已爬楼层", this.todayFlightsClimbed, "层")
          }
        }

      }.padding({left:20,right:20})
      .width("100%")
      .height("100%")
    }
  }
}

