// pages/AppPage.ets
import router from '@ohos.router'

interface  RouTmp{
  title:string
}


@Entry
@Component
export default struct AppPage {
  params: RouTmp = router.getParams() as RouTmp;
  @State title: string = this.params.title;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.left'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
          .fillColor(Color.Blue)
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.left'))
          .width(24)
          .height(24)
          .fillColor(Color.Transparent)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)

      // 页面内容
      Text('App页面内容')
        .fontSize(16)
        .margin(20)
    }
    .width('100%')
    .height('100%')
  }
}