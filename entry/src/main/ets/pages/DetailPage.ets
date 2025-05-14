import router from '@ohos.router';
import { Health, HealthDataStore } from '../model/Health';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import geoLocationManager from '@ohos.geoLocationManager';
import promptAction from '@ohos.promptAction';
import sensor from '@ohos.sensor';
import Intl from '@ohos.intl';
import { CommonConstants } from '../common/constants/CommonConstants';
import LocationUtil from '../common/utils/LocationUtil';
import Logger from '../common/utils/Logger';
import NumberUtil from '../common/utils/NumberUtil';
import StepsUtil from '../common/utils/StepsUtil';



interface RouTmp {
  type: string,
  data: number,
  unit: string,
}

const TAG: string = 'DetailPage';


@Entry
@Component
struct DetailPage {
  params: RouTmp = router.getParams() as RouTmp;
  @State type: string = this.params.type;
  @State data: number = this.params.data;
  @State unit: string = this.params.unit;
  @State selectedTimeRange: string = '周';


  private healthDataStore: HealthDataStore = HealthDataStore.getInstance();
  @StorageLink('healthHistory') healthHistory :Health[]=this.healthDataStore.healthHistory
  @StorageLink('todayHealth') todayHealth:Health= AppStorage.get('todayHealth') ?? this.healthHistory[6];


  // 添加六个健康数据的StorageLink
  @StorageLink('todaySteps') todaySteps: number = 624;
  @StorageLink('todayActiveEnergy') todayActiveEnergy: number = 10.2;
  @StorageLink('todayHeight') todayHeight: number = 173;
  @StorageLink('todayWeight') todayWeight: number = 65.5;
  @StorageLink('todayBMI') todayBMI: number = 21.8;
  @StorageLink('todayFlightsClimbed') todayFlightsClimbed: number = 8;

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
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // private TAG: string = 'DetailPage';

  onPageShow() {
    this.init();
    this.requestPermissions();
  }
  
  
  aboutToAppear() {
    // 初始化步数并请求权限
    this.init();
    this.requestPermissions();
  }
  
  aboutToDisappear() {
    // 关闭传感器监听
    sensor.off(sensor.SensorId.PEDOMETER);
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

  private timeRanges: string[] = ['日', '周', '月', '6个月', '年'];

  private weekDays: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 计算健康数据百分比的函数 - 基于七天数据的最小值到最大值范围计算百分比

  private calculateHealthPercentage(healthParam: string, dayIndex: number): string {
    let healthHistory = this.healthHistory;
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

  // 获取健康参数的英文标识
  private getHealthParam(): string {
    switch (this.type) {
      case '步数':
        return 'steps';
      case '活动能量':
        return 'activeEnergy';
      case '已爬楼层':
        return 'flightsClimbed';
      case '身高':
        return 'height';
      case '体重':
        return 'weight';
      case '身高体重指数':
        return 'bmi';
      default:
        return '';
    }
  }

  // 柱状图Builder函数
  @Builder
  private HistogramChart() {
    Column() {
      // 日期范围显示
      Text('2024年1月12日至18日')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 20 })

      // 柱状图
      Row() {
        ForEach([0, 1, 2, 3, 4, 5, 6], (dayIndex: number) => {
          Column() {
            // 柱子
            Column() {
              Column()
                .width(10)
                .height(this.calculateHealthPercentage(this.getHealthParam(), dayIndex))
                .backgroundColor('#419cff')
                .borderRadius(6)
            }
            .width(16)
            .height(120)
            .justifyContent(FlexAlign.End)

            // 日期标签
            Text(this.weekDays[dayIndex])
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .margin({ right: dayIndex < 6 ? 15 : 0 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .padding(20)
  }
  //
  // // 选项项目Builder函数
  // @Builder
  // private OptionItem(title: string, rightText: string = '', showDivider: boolean = true) {
  //   Column() {
  //     Row() {
  //       Row() {
  //         Text(title)
  //           .fontSize(16)
  //           .fontWeight(FontWeight.Normal)
  //       }
  //       .alignItems(VerticalAlign.Center)
  //
  //       Row() {
  //         if (rightText) {
  //           Text(rightText)
  //             .fontSize(16)
  //             .fontColor('#999999')
  //             .margin({ right: 5 })
  //         }
  //
  //         Image($r('app.media.right'))
  //           .width(16)
  //           .height(16)
  //           .colorBlend("#c4c5c7")
  //       }
  //       .alignItems(VerticalAlign.Center)
  //     }
  //     .width('100%')
  //     .justifyContent(FlexAlign.SpaceBetween)
  //     .alignItems(VerticalAlign.Center)
  //     .padding({ top: 12, bottom: 12 })
  //
  //     if (showDivider) {
  //       Divider()
  //         .strokeWidth(1)
  //         .color('#e0e0e1')
  //         .borderColor(Color.Transparent)
  //         .backgroundColor(Color.Transparent)
  //     }
  //   }
  // }

  // 获取最后一天的健康参数值
  private getLatestHealthValue(): string {
    // 获取当前健康参数类型
    const healthParam = this.getHealthParam();
    
    // 确保健康历史数据存在
    if (!this.healthHistory || this.healthHistory.length === 0) {
      return this.data.toString();
    }
    
    // 获取最后一条记录
    const lastRecord = this.healthHistory[this.healthHistory.length - 1];
    let value: number;
    
    // 根据参数类型获取对应的值
    switch (healthParam) {
      case 'steps':
        value = lastRecord.steps;
        break;
      case 'activeEnergy':
        value = lastRecord.activeEnergy;
        break;
      case 'flightsClimbed':
        value = lastRecord.flightsClimbed;
        break;
      case 'heartRate':
        value = lastRecord.heartRate;
        break;
      case 'sleepAnalysis':
        value = lastRecord.sleepAnalysis;
        break;
      case 'bloodOxygen':
        value = lastRecord.bloodOxygen;
        break;
      case 'bodyTemperature':
        value = lastRecord.bodyTemperature;
        break;
      case 'stressLevel':
        value = lastRecord.stressLevel;
        break;
      case 'bmi':
        value = lastRecord.bmi;
        break;
      case 'height':
        value = lastRecord.height;
        break;
      case 'weight':
        value = lastRecord.weight;
        break;
      default:
        value = this.data;
    }
    
    // 返回格式化后的值（保留一位小数）
    if (Number.isInteger(value)) {
      return value.toString();
    } else {
      return value.toFixed(1);
    }
  }



  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.left'))
            .width(24)
            .height(24)
            .fillColor('#007AFF')
          Text('摘要')
            .fontSize(16)
            .fontColor('#007AFF')
        }
        .onClick(() => router.back())

        Text(this.type)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Text('添加数据')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            this.isShowSheet = true;
          })
          .bindSheet(
            $$this.isShowSheet,
            this.AddDataSheet(),
            {
              detents: [SheetSize.MEDIUM],
              preferType: SheetType.BOTTOM,
              showClose: false,
              dragBar: false,
              blurStyle: BlurStyle.Thick,
              backgroundColor: Color.White
            }
          )
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 主内容区域 - 使用List和ListItem结构
      List() {
        // 数据展示区域
        ListItem() {
          Column() {
            Row(){
              Text(this.getLatestHealthValue())
                .fontSize(40)
                .fontWeight(FontWeight.Bold)

              Text(this.unit)
                .fontSize(16)
                .fontColor('#999999')
            }
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .margin({ top: 20, bottom: 20 })
        }

        // 时间选择器
        ListItem() {
          Tabs({ barPosition: BarPosition.Start, index: 1 }) {
            ForEach(this.timeRanges, (item: string) => {
              TabContent() {
                if (item === '周') {
                  this.HistogramChart()
                } else {
                  // 其他时间范围的图表（占位）
                  Column() {
                    Text(`${item}数据图表`)
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .height(200)
                  .backgroundColor(Color.White)
                  .borderRadius(10)
                  .justifyContent(FlexAlign.Center)
                }
              }
              .tabBar(this.TabBuilder(item))
            })
          }
          .barMode(BarMode.Fixed)
          .barWidth('100%')
          .barHeight(50)

          .animationDuration(300)
          .onChange((index: number) => {
            this.selectedTimeRange = this.timeRanges[index];
          })
          .width('100%')
          .height(300)
          .backgroundColor('#F5F5F5')
          .margin({ top: 10 })
        }

        // 选项标题
        ListItem() {
          Text("选项")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 20, bottom: 10 })
        }

        // 选项区域 - 白色背景容器
        ListItem() {
          Column() {
            // 取消在"摘要"中置顶选项
            Row() {
              Row() {
                Text("取消在\"摘要\"中置顶")
                  .fontSize(16)
                  .fontWeight(FontWeight.Normal)
              }
              .alignItems(VerticalAlign.Center)

              Row() {
                Image($r('app.media.right'))
                  .width(16)
                  .height(16)
                  .colorBlend("#c4c5c7")
              }
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })

          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding({ left: 16, right: 16 })
        }

        // 置顶主题说明文字
        ListItem() {
          Text("置顶主题将在\"摘要\"顶部显示。")
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 5, bottom: 15 })
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.Transparent)
            .width('100%')
        }

        // 显示所有数据选项
        ListItem() {
          Column() {
            Row() {
              Text("显示所有数据")
                .fontSize(16)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.right'))
                .width(16)
                .height(16)
                .colorBlend("#c4c5c7")
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })

            Divider()
              .strokeWidth(1)
              .color('#e0e0e1')
              .borderColor(Color.Transparent)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: 16, right: 16 })
        }

        // 数据源与访问选项
        ListItem() {
          Column() {
            Row() {
              Text("数据源与访问")
                .fontSize(16)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.right'))
                .width(16)
                .height(16)
                .colorBlend("#c4c5c7")
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })

            Divider()
              .strokeWidth(1)
              .color('#e0e0e1')
              .borderColor(Color.Transparent)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: 16, right: 16 })
        }

        // 数据源与访问选项
        ListItem() {
          Column() {
            Row() {
              Text("安全与隐私")
                .fontSize(16)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.right'))
                .width(16)
                .height(16)
                .colorBlend("#c4c5c7")
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })

            Divider()
              .strokeWidth(1)
              .color('#e0e0e1')
              .borderColor(Color.Transparent)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .padding({ left: 16, right: 16 })
        }

        // 单位选项
        ListItem() {
          Row() {
            Text("单位")
              .fontSize(16)
              .fontWeight(FontWeight.Normal)

            Row() {
              Text(this.unit)
                .fontSize(16)
                .fontColor('#999999')
                .margin({ right: 5 })

              Image($r('app.media.right'))
                .width(16)
                .height(16)
                .colorBlend("#c4c5c7")
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .padding({ top: 12, bottom: 12, left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(10)
        }
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private TabBuilder(name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedTimeRange === name ? '#000000' : '#999999')
        .fontSize(16)
        .fontWeight(this.selectedTimeRange === name ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedTimeRange === name ? '#FFFFFF' : '#F5F5F5')
    .borderRadius(this.selectedTimeRange === name ? 8 : 0)
  }

  @State isShowSheet: boolean = false;
  @State selectedDate: Date = new Date();
  @State selectedTime: Date = new Date();
  @State inputValue: string = ''


  @Builder
  private AddDataSheet() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            this.isShowSheet = false;
          })

        Text(this.type)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Text('添加')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            // 更新最后一天的数据
            this.data = Number(this.inputValue)
            let healthHistory = this.healthHistory;
            let todayHealth = this.todayHealth

            if (healthHistory && healthHistory.length > 0) {
              const lastRecord = healthHistory[healthHistory.length - 1];
              const value = parseFloat(this.inputValue);

              switch (this.getHealthParam()) {
                case 'steps':
                  lastRecord.steps = value;
                  todayHealth.steps = value;
                  this.todaySteps = value;
                  break;
                case 'activeEnergy':
                  lastRecord.activeEnergy = value;
                  todayHealth.activeEnergy = value;
                  this.todayActiveEnergy = value;
                  break;
                case 'flightsClimbed':
                  lastRecord.flightsClimbed = value;
                  todayHealth.flightsClimbed = value;
                  this.todayFlightsClimbed = value;
                  break;
                case 'heartRate':
                  lastRecord.heartRate = value;
                  todayHealth.heartRate = value;
                  break;
                case 'sleepAnalysis':
                  lastRecord.sleepAnalysis = value;
                  todayHealth.sleepAnalysis = value;
                  break;
                case 'bloodOxygen':
                  lastRecord.bloodOxygen = value;
                  todayHealth.bloodOxygen = value;
                  break;
                case 'bodyTemperature':
                  lastRecord.bodyTemperature = value;
                  todayHealth.bodyTemperature = value;
                  break;
                case 'stressLevel':
                  lastRecord.stressLevel = value;
                  todayHealth.stressLevel = value;
                  break;
                case 'bmi':
                  lastRecord.bmi = value;
                  todayHealth.bmi = value;
                  this.todayBMI = value;
                  break;
                case 'height':
                  lastRecord.height = value;
                  todayHealth.height = value;
                  this.todayHeight = value;
                  // 身高更新后重新计算BMI
                  if (todayHealth.weight > 0) {
                    const newBMI = Math.round((todayHealth.weight / (value * value / 10000)) * 10) / 10;
                    lastRecord.bmi = newBMI;
                    todayHealth.bmi = newBMI;
                    this.todayBMI = newBMI;
                    // 更新全局BMI
                    AppStorage.set('currentBMI', newBMI);
                  }
                  break;
                case 'weight':
                  lastRecord.weight = value;
                  todayHealth.weight = value;
                  this.todayWeight = value;
                  // 体重更新后重新计算BMI
                  if (todayHealth.height > 0) {
                    const newBMI = Math.round((value / (todayHealth.height * todayHealth.height / 10000)) * 10) / 10;
                    lastRecord.bmi = newBMI;
                    todayHealth.bmi = newBMI;
                    this.todayBMI = newBMI;
                    // 更新全局BMI
                    AppStorage.set('currentBMI', newBMI);
                  }
                  break;
              }
            }
            AppStorage.set("healthHistory", [...healthHistory])
            AppStorage.set("todayHealth", todayHealth)
            // 确保数据同步到AppStorage
            AppStorage.set('todaySteps', this.todaySteps);
            AppStorage.set('todayActiveEnergy', this.todayActiveEnergy);
            AppStorage.set('todayHeight', this.todayHeight);
            AppStorage.set('todayWeight', this.todayWeight);
            AppStorage.set('todayBMI', this.todayBMI);
            AppStorage.set('todayFlightsClimbed', this.todayFlightsClimbed);


            // 添加弹窗提醒
            promptAction.showDialog({
              title: '数据更新成功',
              message: `您的${this.type}数据已成功更新为${this.inputValue}${this.unit}`,
              buttons: [
                {
                  text: '确定',
                  color: '#007AFF',
                }
              ],

              alignment: DialogAlignment.Center,
              offset: { dx: 0, dy: -100 } // 使弹窗在屏幕中央偏上位置显示
            }).then(() => {
              // 关闭底部弹出层
              this.isShowSheet = false;
            });


            this.isShowSheet = false;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      Column() {
        Row() {
          Text('日期')
            .fontSize(16)
          TextInput({text: this.selectedDate.toLocaleDateString()})
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .padding(10)
            .borderRadius(8)
            .margin({ left: 10 })
            .width("80%")
            .enableKeyboardOnFocus(false)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date(),
                selected: this.selectedDate,
                onDateAccept: (date) => {
                  this.selectedDate = date;
                }
              });
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20 })
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('时间')
            .fontSize(16)
          TextInput({text: this.selectedTime.toLocaleTimeString()})
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .padding(10)
            .borderRadius(8)
            .margin({ left: 10 })
            .width("80%")
            .enableKeyboardOnFocus(false)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("1900-1-1"),
                end: new Date(),
                selected: this.selectedDate,
                useMilitaryTime:false,
                onDateAccept:((date)=>{
                  this.selectedDate=date;
                })
              })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text(this.unit)
            .fontSize(16)
          TextInput({ placeholder: '输入数值' })
            .backgroundColor('#F5F5F5')
            .padding(10)
            .borderRadius(8)
            .margin({ left: 10 })
            .width("80%")
            .type(InputType.Number)
            .onChange((value: string) => {
              this.inputValue = value;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor(Color.White)
    }
  }
}