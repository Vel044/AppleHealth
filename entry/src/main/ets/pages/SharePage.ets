// pages/SharePage.ets

@Entry
@Component

export default struct SharePage {

  @Builder
  ShareBuilder(resourse:Resource,text1:string,text2:string){
    Row(){
      Image(resourse)
        .colorBlend(Color.Blue)
        .width("15%")
        .margin({right:10})
      Column(){
        Text(text1)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({bottom:3})
          .width("100%")
          .fontSize(14)
        Text(text2)
          .textAlign(TextAlign.Start)
          .fontColor(Color.Gray)
          .width("100%")
          .fontSize(14)
      }.width("70%")
      .justifyContent(FlexAlign.Start)
      .margin({top:15,bottom:15})
    }
  }

  appAndResearch: string[] = ['App', '调研'];

  build() {
    List(){
      // 共享
      ListItem(){
        Text("共享")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .width("100%")
      }

      // 健康共享
      ListItem(){


        Column(){
          Image($r("app.media.share"))
            .height(60)
            .colorBlend(Color.Blue)
            .margin({top:15})
          Text("健康共享")
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width("100%")
          this.ShareBuilder($r("app.media.todo"),"掌控权在你手中","安全共享你的健康数据，使亲友及时" +
            "了解你的健康状况。")
          this.ShareBuilder($r("app.media.bell"),"图表汇总和通知","你共享的数据将在其“健康”App中" +
            "显示。有更新时还可向共享对象发送" +
            "通知。")
          this.ShareBuilder($r("app.media.lock"),"私密且安全","仅分享每个主题的摘要，而非详细信" +
            "息。信息会加密，你可以随时停止" +
            "共享。")

          Button('与他人共享', { type: ButtonType.Capsule })
            .backgroundColor("#007Aff")
            .width("90%")
            .height(50)
            .borderRadius(15)
            .type(ButtonType.Normal)
            .margin({ top:5,bottom:5 })
          Button('请求他人共享', { type: ButtonType.Capsule })
            .backgroundColor("#eeeeef")
            .width("90%")
            .height(50)
            .borderRadius(15)
            .type(ButtonType.Normal)
            .margin({ top:5,bottom:20 })
            .fontColor("#007Aff")

        }.borderRadius(10)
        .backgroundColor(Color.White)
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top:5,bottom:10 })

      }
      // APP 和 调研

      ListItem(){

        Column(){
          ForEach(this.appAndResearch, (item: string,index:number) => {
            ListItem() {
              Column(){
                Row() {
                  Text(item)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  Image($r("app.media.right_click"))
                    .width(20)
                    .height(20)
                    .colorBlend(Color.Gray)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left:16,right:16,top:14,bottom:14 })
                .width('100%')
                .backgroundColor(Color.Transparent)
                if(index<1) {
                  Divider()
                    .height(1)
                    .margin({ left: 16 })
                }
              }

            }
            .onClick(() => {
              // 页面跳转逻辑
            })
          }, (item: string) => item)

        }.borderRadius(10)
        .backgroundColor(Color.White)
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)

      }

      // 正在与你共享
      ListItem(){
        Text("正在与你共享")
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .width("100%")
          .textAlign(TextAlign.Start)
          .margin({ top:20,bottom:5 })

      }
      // 尚无人与你共享数据
      ListItem(){
        Text("   尚无人与你共享数据")
          .fontSize(10)
          .fontColor(Color.Gray)
          .width("100%")
          .textAlign(TextAlign.Start)
          .margin({ top:10,bottom:5 })
      }


    }.padding({left:20,right:20})




  }
}