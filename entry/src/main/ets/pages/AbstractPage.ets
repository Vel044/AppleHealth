// pages/AbstractPage.ets
import { Health, DefaultHealth,HealthDataStore } from "../model/Health"
import { UserInfo, defaultUserInfo } from '../model/UserInfo';

import router from '@ohos.router'


@Entry
@Component
export default struct AbstractPage {
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? defaultUserInfo;
  @StorageLink('currentBMI') tempBMI: number = 0;
  date:Date=new Date();

  @StorageLink('todayHealth') todayHealth:Health= AppStorage.get('todayHealth') ?? DefaultHealth;

  healthDataStore: HealthDataStore = HealthDataStore.getInstance();
  @StorageLink('healthHistory') healthHistory :Health[]=this.healthDataStore.healthHistory


  aboutToAppear(): void {
    // 计算BMI值
    this.calculateBMI();
    // 同步用户信息到健康数据
    if (this.userInfo && this.userInfo.userHeight > 0 && this.userInfo.weight > 0) {
      this.todayHealth.height = this.userInfo.userHeight;
      this.todayHealth.weight = this.userInfo.weight;
      this.todayHealth.bmi = this.tempBMI;
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
    const record = healthHistory[index];

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
            Text(data+"")
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


        // 修改调用部分
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
  private bodyTemplate(fitness: string = "身高体重指数", data: number = this.tempBMI, unit: string = "BMI") {
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
          data: data,
          unit: unit
        }
      });
    })
  }


  build() {

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
          this.fitnessTemplate("步数",this.todayHealth.steps,"步")
          this.fitnessTemplate("活动能量",this.todayHealth.activeEnergy,"千卡")
          this.bodyTemplate("身高", this.todayHealth.height, "cm")
          this.bodyTemplate("体重", this.todayHealth.weight, "kg")
          this.bodyTemplate("身高体重指数", this.tempBMI, "BMI")
          this.fitnessTemplate("已爬楼层",this.todayHealth.flightsClimbed,"层")
        }
      }

    }.padding({left:20,right:20})

  }
}