// pages/AbstractPage.ets

import { Health, DefaultHealth } from "../model/Health"
import { UserInfo, defaultUserInfo } from '../model/UserInfo';




@Entry
@Component
export default struct AbstractPage {

  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? defaultUserInfo;
  @StorageLink('currentBMI') tempBMI: number = 0;
  date:Date=new Date();

  @State todayHealth:Health=DefaultHealth;
  // @State tempBMI:number = 0; // 新增一个单独的BMI状态变量

  aboutToAppear(): void {
    // 计算BMI值
    this.calculateBMI();
  }
  
  calculateBMI(): void {
    if (this.userInfo && this.userInfo.userHeight > 0 && this.userInfo.weight > 0) {
      this.tempBMI = Math.round((this.userInfo.weight / (this.userInfo.userHeight * this.userInfo.userHeight / 10000)) * 10) / 10;
    }
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

        Text("这边后面需要绘图")
          .alignSelf(ItemAlign.End)
          .margin(10)

      }.width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .height(80)


    }.borderRadius(10)
    .backgroundColor(Color.White)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top:5,bottom:5 })

  }

  @Builder
  private bodyTemplate (){
    Column(){
      Row(){
        Row(){
          Image($r("app.media.people"))
            .height(20)
            .margin(5)
            .colorBlend(Color.Blue)
          Text("身高体重指数")
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
            Text(this.tempBMI + "") // 使用新的tempBMI变量替代todayHealth.bmi
              .fontSize(30)
              .alignSelf(ItemAlign.End)
              .fontWeight(FontWeight.Bold)

            Text("BMI")
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


        Text("绘图")

      }.width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .height(80)


    }.borderRadius(10)
    .backgroundColor(Color.White)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top:5,bottom:5 })
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
          this.bodyTemplate()
          this.fitnessTemplate("已爬楼层",this.todayHealth.flightsClimbed,"层")
        }
      }

    }.padding({left:20,right:20})

  }
}