// pages/Index.ets
import { UserInfo, defaultUserInfo } from '../model/UserInfo';
import { Health, DefaultHealth,HealthDataStore } from "../model/Health"
import UserInfoCollect from './UserInfoCollect';
import AbstractPage from './AbstractPage';
import SharePage from  './SharePage';
import BrowsePage from  './BrowsePage';


// 确保在应用启动时就初始化持久化存储
PersistentStorage.persistProp('userInfo', defaultUserInfo);


@Entry
@Component
struct Index {
  // 直接从AppStorage读取，如果不存在则使用默认值
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? defaultUserInfo;

  @State isShow:boolean = !this.validateUserInfoCompleteness();

  private validateUserInfoCompleteness(): boolean {
    return !!this.userInfo.surName &&
      !!this.userInfo.givenName &&
      this.userInfo.surName.length > 0 &&
      this.userInfo.givenName.length > 0 &&
      this.userInfo.userHeight > 0 &&
      this.userInfo.weight > 0
  }




  @Builder UserInfoCollectBuilder(){
    UserInfoCollect({ showSheet: $isShow })

      .transition({ type: TransitionType.Delete, opacity: 0 })
  }


  build() {
    Column() {
      // if (this.validateUserInfoCompleteness()) {
      //   MainTabs()
      //     .transition({ type: TransitionType.Insert, scale: { x: 0.9, y: 0.9 } })
      // } else {
      //   UserInfoCollect()
      //     .transition({ type: TransitionType.Delete, opacity: 0 })
      // }

      MainTabs()
        .transition({ type: TransitionType.Insert, scale: { x: 0.9, y: 0.9 } })
        .bindSheet(
          $$this.isShow,
          this.UserInfoCollectBuilder(),
          {
            detents: [SheetSize.LARGE, SheetSize.LARGE, SheetSize.LARGE],
            preferType: SheetType.BOTTOM,
            showClose: false,
            dragBar: false,
            blurStyle: BlurStyle.Thick,

            backgroundColor: Color.White,

            onWillAppear: () => {
              console.log("onWillAppear\n")
            },
            onAppear: () => {
              console.log("onAppear\n")
            },
            onWillDisappear: () => {
              console.log("onWillDisappear\n")

            },
            onDisappear: () => {
              console.log("onDisappear\n")
            },
            onWillDismiss: () => {
              console.log("onWillDismiss\n");
              // 弹窗显示后，用户点击返回按钮时，如果需要关闭弹窗则手动将 isShow 设置为 false 即可
              this.isShow = false


            }



          }
        )

    }
    .width('100%')
    .height('100%')
  }

}


@Component
struct MainTabs {
  @State currentTab: number = 0
  mediaIndex:Resource[]=[$r("app.media.heart"),$r("app.media.share"),$r("app.media.browse")]
  textIndex:string[]=["摘要","分享","浏览"]



  @Builder tabBarDynamic( index :number) {   // 自定义动态标签
    Column() {
      Image(this.mediaIndex[index])
        .size({ width: 28, height: 28 })
        .fillColor(this.currentTab == index? "#007AFF" : "#959595")

      Text(this.textIndex[index])
        .fontSize(8)
        .fontColor(this.currentTab == index ? "#007AFF" : "#959595")

    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        AbstractPage()
      }.tabBar(this.tabBarDynamic(0))

      TabContent() {
        SharePage()
      }.tabBar(this.tabBarDynamic(1))

      TabContent() {
        BrowsePage()
      }.tabBar(this.tabBarDynamic(2))
    }
    .barMode(BarMode.Fixed)
    .onChange((index)=>this.currentTab=index)
    .width('100%')
    .height('100%')
    .barBackgroundColor("#f7f7f7")
    .backgroundColor("#f2f2f7")
    .divider({strokeWidth:1})


  }
}