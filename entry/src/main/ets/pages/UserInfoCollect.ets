// pages/UserInfoCollect.ets
import { UserInfo, defaultUserInfo } from '../model/UserInfo';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { Health ,HealthDataStore} from '../model/Health';

const TAG: string = '[PublishOperation]';
const DOMAIN_NUMBER: number = 0xFF00;

// 生成身高范围 50cm ~ 220cm（步长1cm）
const HEIGHT_RANGE: string[] = [];
for (let cm = 50; cm <= 220; cm++) {
  HEIGHT_RANGE.push(`${cm}cm`);
}

// 生成体重范围 30.0kg ~ 200.0kg（步长0.5kg）
const WEIGHT_RANGE: string[] = [];
// 用整数计算避免浮点误差（30kg=60个0.5单位，200kg=400个0.5单位）
for (let unit = 60; unit <= 400; unit++) { // 30*2=60 ~ 200*2=400
  const kg = unit * 0.5;
  WEIGHT_RANGE.push(`${kg.toFixed(1)}kg`);
}


@Component
export default struct UserInfoCollect {
  @StorageLink('userInfo') userInfo: UserInfo = defaultUserInfo;
  @State tempUserInfo: UserInfo = defaultUserInfo;
  @State tempBirthday: Date=new Date();
  @State currentPage: number = 0;
  @State prevStep: number = -1;
  // 0:欢迎页 1:隐私页 2:通知页 3:信息页
  @Link showSheet: boolean;

  private swiperController: SwiperController = new SwiperController()

  private healthDataStore: HealthDataStore = HealthDataStore.getInstance();
  @StorageLink('healthHistory') healthHistory :Health[]=this.healthDataStore.healthHistory
  @StorageLink('todayHealth') todayHealth:Health= AppStorage.get('todayHealth') ?? this.healthHistory[6];

  // 0.欢迎页
  @Builder
  private WelcomePage() {
    Column({ space: 20 }) {
      Blank()
        .height("5%")

      Image($r('app.media.welcomeIcon'))
        .width("95%")
      Text('欢迎使用“健康”')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)


      Text('此App可集中一处展示你的健康信息。\n\n你可以查看重要的变化或提醒，深\n入分析你的数据，并了解重要主题。')
        .fontSize(17)
        .textAlign(TextAlign.Center)
      Blank()
        .height("12%")

      Button('继续', { type: ButtonType.Capsule })
        .onClick(() => this.swiperController.showNext())
        .backgroundColor("#419cff")
        .width("90%")
        .height(50)
        .borderRadius(15)
        .type(ButtonType.Normal)

    }
    .padding(20)
    .width('100%')
  }


  // 在页面中添加返回按钮
  // 1.隐私协议页
  @Builder
  private PrivacyPage() {
    Column({ space: 20 }) {

      Row(){
        Row() {
          Image($r('app.media.left'))
            .width(24)
            .height(24)
            .fillColor('#007AFF')
          Text('返回')
            .fontSize(16)
            .fontColor('#007AFF')
        }.onClick(() => this.swiperController.showPrevious())

        Blank()
          .width("100%")
      }

      Image($r('app.media.securityIcon'))
        .height('15%')
      Blank()
        .height(20)

      Text('你的健康数据\n私密且安全')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)


      Text('为保护你的隐私，设备上的\n' +
        '健康数据会在其锁定时加密。\n\n' +
        '未经你的许可，此类数据无法被包括Huawei\n' +
        '在内的任何人读取，且绝不会出售给第三方。\n\n' +
        '你始终可以控制共享你健康数据的\n' +
        'App和联系人，也可以随时关闭共享。')
        .fontSize(14)
        .textAlign(TextAlign.Center)

      Text('进一步了解...')
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .fontColor("#007AFF")

      Blank()
        .height("12%")


      Button('继续', { type: ButtonType.Capsule })
        .onClick(() => this.swiperController.showNext())
        .backgroundColor("#419cff")
        .width("90%")
        .height(50)
        .borderRadius(15)
        .type(ButtonType.Normal)
      Blank()
        .height(40)
    }
    .padding(20)
    .width('100%')
  }


  // 2.通知权限页
  @Builder
  private NotificationPage() {
    Column({ space: 20 }) {
      Row(){
        Row() {
          Image($r('app.media.left'))
            .width(24)
            .height(24)
            .fillColor('#007AFF')
          Text('返回')
            .fontSize(16)
            .fontColor('#007AFF')
        }.onClick(() => this.swiperController.showPrevious())
        Blank()
          .width("100%")
      }

      Image($r('app.media.informIcon'))
        .height('15%')


      Text('健康通知')
        .fontSize(35)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text('“健康”App可在出现需要\n你关注的情况时通知你。')
        .fontSize(16)
        .textAlign(TextAlign.Center)

      Row(){
        Text('更多通知')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
        Blank()
          .width("100%")
      }

      Row({space:10}){
        Image($r("app.media.trend"))
          .width("10%")
        Column(){
          Text('趋势')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
          Text('在你的健康数据出现新趋势时\n接收通知')
            .fontSize(17)
            .textAlign(TextAlign.Start)
            .fontColor(Color.Gray)

        }
        Toggle({type:ToggleType.Switch,isOn : true})
          .onChange((value)=>this.userInfo.notificationAllowed=value)
      }
      Blank()
        .height("20%")


      Button('继续', { type: ButtonType.Capsule })
        .onClick(() => {
          if(this.userInfo.notificationAllowed){
            // 向用户请求授权
            let context = getContext(this) as common.UIAbilityContext;
            notificationManager.isNotificationEnabled().then((data: boolean) => {
              hilog.info(DOMAIN_NUMBER, TAG, "isNotificationEnabled success, data: " + JSON.stringify(data));
              if(!data){
                notificationManager.requestEnableNotification(context).then(() => {
                  hilog.info(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification success`);
                }).catch((err : BusinessError) => {
                  if(1600004 == err.code){
                    hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
                  } else {
                    hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
                  }
                });
              }
            }).catch((err : BusinessError) => {
              hilog.error(DOMAIN_NUMBER, TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
            });

          }

          this.swiperController.showNext()
        })
        .backgroundColor("#419cff")
        .width("90%")
        .height(50)
        .borderRadius(15)
        .type(ButtonType.Normal)
      Blank()
        .height(40)
    }
    .padding(20)
  }


  // 3.信息收集页
  @Builder
  private InfoCollectPage() {
    Column({ space:10 }) {
      Row(){
        Row() {
          Image($r('app.media.left'))
            .width(24)
            .height(24)
            .fillColor('#007AFF')
          Text('返回')
            .fontSize(16)
            .fontColor('#007AFF')
        }.onClick(() => this.swiperController.showPrevious())

        Blank()
          .width("100%")
      }.margin(20)
      Image($r("app.media.profile"))
        .borderRadius(30)
        .height(60)
      Text('设置健康详细信息')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text('你的健康详细信息是APP为你提供相关信息\n所需的基本信息。')
        .fontSize(16)
        .textAlign(TextAlign.Center)

      Blank()
        .height("10%")

      Divider()
        .strokeWidth(1)

      Column(){
        Row(){
          Text('姓氏')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .fontWeight(FontWeight.Bold)

          TextInput({ placeholder: '姓氏', text: this.tempUserInfo.surName })
            .onChange((value: string) => this.tempUserInfo.surName = value)
            .width("67%")
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Start)
        }
        Divider()
          .strokeWidth(1)
          .margin({ top:5 ,bottom:5})
        Row(){
          Text('名字')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .fontWeight(FontWeight.Bold)

          TextInput({ placeholder: '名字', text: this.tempUserInfo.givenName })
            .onChange((value: string) => this.tempUserInfo.givenName = value)
            .width("67%")
            .textAlign(TextAlign.Start)
            .backgroundColor(Color.White)

        }
        Divider()
          .strokeWidth(1)
          .margin({ top:5 ,bottom:5 })
        Row(){
          Text('生日')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .fontWeight(FontWeight.Bold)
          TextInput( {text:this.tempUserInfo.birthday.getFullYear()+"年"+
          this.tempUserInfo.birthday.getMonth()+"月"+
          this.tempUserInfo.birthday.getDay()+"日"})
            .width("67%")
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Start)
            .focusable(false)
            .enableKeyboardOnFocus(false)

            .onClick(()=>{
              DatePickerDialog.show({
                start: new Date("1900-1-1"),
                end: new Date(),
                selected: this.tempUserInfo.birthday,
                useMilitaryTime:false,
                onDateAccept:((date)=>{
                  this.tempUserInfo.birthday=date;
                })
              })
            })
        }

        Divider()
          .strokeWidth(1)
          .margin({ top:5 ,bottom:5 })

        Row(){
          Text('性别')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .focusable(false)
            .fontWeight(FontWeight.Bold)
          TextInput( {text:this.tempUserInfo.gender})
            .width("67%")
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Start)
            .enableKeyboardOnFocus(false)
            .focusable(false)
            .onClick(()=>{
              TextPickerDialog.show({
                range:["男","女"],
                selected : this.tempUserInfo.gender == "男" ? 0 : 1 ,
                canLoop:false,
                onAccept:((gender)=> {
                  this.tempUserInfo.gender = gender.value as string
                }),
              }
              )
            })
        }

        Divider()
          .strokeWidth(1)
          .margin({ top:5 ,bottom:5  })
        // 身高选择器组件
        Row() {
          Text('身高')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .fontWeight(FontWeight.Bold)

          TextInput({text:this.tempUserInfo.userHeight ? `${this.tempUserInfo.userHeight}cm` : '请选择身高'})
            .width("67%")
            .enableKeyboardOnFocus(false)
            .focusable(false)
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Start)
            .onClick(() => {
              const selectedIndex = this.tempUserInfo.userHeight
                ? this.tempUserInfo.userHeight - 140 // 140cm对应索引0
                : 0;

              TextPickerDialog.show({
                range: HEIGHT_RANGE,
                selected: selectedIndex,
                onAccept: (result) => {
                  const heightValue = parseInt(result.value.toString().substring(0,result.value.length-2));
                  this.tempUserInfo.userHeight = heightValue;
                }
              });
            })
        }
        Divider()
          .strokeWidth(1)
          .margin({ top:5 ,bottom:5  })
        // 体重选择器组件
        Row() {
          Text('体重')
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .width("33%")
            .fontWeight(FontWeight.Bold)

          TextInput({text:this.tempUserInfo.weight ? `${this.tempUserInfo.weight.toFixed(1)}kg` : '请选择体重'})
            .width("67%")
            .backgroundColor(Color.White)
            .textAlign(TextAlign.Start)
            .enableKeyboardOnFocus(false)
            .focusable(false)
            .onClick(() => {
              const selectedIndex = this.tempUserInfo.weight
                ? Math.round((this.tempUserInfo.weight - 30) * 2) // 30kg对应索引0
                : 0;

              TextPickerDialog.show({
                range: WEIGHT_RANGE,
                selected: selectedIndex,
                onAccept: (result) => {
                  const weightValue = parseFloat(result.value.toString().substring(0,result.value.length-2));
                  this.tempUserInfo.weight = weightValue;

                }
              });
            })
        }
      }.margin({left:20,right:20})
      Divider()
        .strokeWidth(1)
        .margin({bottom:5})

      Button('下一步', { type: ButtonType.Capsule })
        .onClick(() => {
          console.log('用户信息已保存:');
          this.userInfo = this.tempUserInfo;
          AppStorage.setOrCreate("userInfo", this.userInfo)

          let healthHistory = this.healthHistory;
          let todayHealth = this.todayHealth

          const lastRecord = healthHistory[healthHistory.length - 1];

      
          // 计算并更新BMI值
          const bmi = Math.round((this.userInfo.weight / (this.userInfo.userHeight * this.userInfo.userHeight / 10000)) * 10) / 10;
          // 更新持久化存储数据
          AppStorage.setOrCreate('currentBMI', bmi);
          AppStorage.setOrCreate('todayHeight', this.userInfo.userHeight);
          AppStorage.setOrCreate('todayWeight', this.userInfo.weight);
          AppStorage.setOrCreate('todayBMI', bmi);


          lastRecord.bmi=bmi;
          lastRecord.height=this.userInfo.userHeight;
          lastRecord.weight=this.userInfo.weight;
          this.healthHistory[6]=lastRecord;
          AppStorage.setOrCreate('healthHistory',  this.healthHistory);

          
          this.showSheet = false;
        })
    }

  }


  // 修改后的页面构建方法
  build() {
    // Stack({ alignContent: Alignment.Center }) {
    //   // 0.欢迎页
    //   if (this.currentStep === 0) {
    //     Column() {
    //       this.WelcomePage()
    //     }
    //     .transition(this.getTransitionEffect(0))
    //   }
    //
    //   // 1.隐私协议页
    //   if (this.currentStep === 1) {
    //     Column() {
    //       this.PrivacyPage()
    //     }
    //     .transition(this.getTransitionEffect(1))
    //   }
    //
    //   // 2.通知权限页
    //   if (this.currentStep === 2) {
    //     Column() {
    //       this.NotificationPage()
    //     }
    //     .transition(this.getTransitionEffect(2))
    //   }
    //
    //   // 3.信息收集页
    //   if (this.currentStep === 3) {
    //     Column() {
    //       this.InfoCollectPage()
    //     }
    //     .transition(this.getTransitionEffect(3))
    //   }
    // }
    // .width('100%')
    // .height('100%')

    Column(){
      Swiper(this.swiperController) {
        RelativeContainer() {
          this.WelcomePage()
        }
        RelativeContainer() {
          this.PrivacyPage()
        }
        RelativeContainer() {
          this.NotificationPage()
        }
        RelativeContainer() {
          this.InfoCollectPage()
        }



      }.width('100%')
      .height('100%')
      .indicator(false)
      .loop(false)
      .index(this.currentPage)
      .onContentWillScroll((result: SwiperContentWillScrollResult) => {
        // if (result.comingIndex > this.currentIndex) {
        //   return false;
        // }
        // return true;

        return false;
      })
      .onChange((index: number) => {
        this.currentPage = index
      })
    }
  }

  // // 跳转处理方法
  // private handleStepChange(newStep: number) {
  //   animateTo({
  //     duration: 500,
  //     curve: Curve.Ease
  //   }, () => {
  //     this.prevStep = this.currentStep;
  //     this.currentStep = newStep;
  //   });
  // }
  //
  // // 动态过渡效果生成器
  // private getTransitionEffect(step: number) {
  //   const baseEffect = TransitionEffect.OPACITY;
  //   return step > this.prevStep
  //     ? baseEffect.combine(TransitionEffect.translate({ x: 100 }))
  //     : baseEffect.combine(TransitionEffect.translate({ x: -100 }));
  // }


  private validateForm(): boolean {
    return !!this.tempUserInfo.surName &&
      !!this.tempUserInfo.givenName &&
      this.tempUserInfo.surName.length > 0 &&
      this.tempUserInfo.givenName.length > 0 &&
      this.tempUserInfo.userHeight > 0 &&
      this.tempUserInfo.weight > 0
  }
}

@Entry
@Component
struct UserInfoCollectTest{
  build() {
  }
}