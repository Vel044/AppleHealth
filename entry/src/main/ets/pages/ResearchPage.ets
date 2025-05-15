// pages/ResearchPage.ets
import router from '@ohos.router'


// 路由参数
interface  RouTmp{
  title:string
}

@Entry
@Component
export default struct ResearchPage {
  // 获得路由参数
  params: RouTmp = router.getParams() as RouTmp;
  @State title: string = this.params.title;


  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.left'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back()
          })
          .fillColor(Color.Transparent)
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })

      // 主体内容
      Column() {
        // 调研标题
        Text("调研")
          .fontSize(16)
          .fontColor(Color.Gray)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 20, bottom: 10 })

        // 无内容卡片
        Column() {
          Text("无")
            .fontSize(16)
            .fontColor(Color.Black)
            .padding({ top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(10)
        .margin({ bottom: 20 })

        // 说明文字
        Text("调研机构请求获取数据的读取权限之后，将被添加到列表中。你可以前往\"研究\"App查看并管理所有已注册研究。")
          .fontSize(14)
          .fontColor(Color.Gray)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 10 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}