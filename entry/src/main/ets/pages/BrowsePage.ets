// pages/BrowsePage.ets
import router from '@ohos.router'

interface HealthCategory{
  icon: Resource,
  title: string,
  color: ResourceColor|string
}

let Purple: string = "#E6E6FA";
let Turquoise: string = "#40e0d0";

@Entry
@Component
export default struct BrowsePage {
  // 健康类别数据
  private healthCategories: Array<HealthCategory> = [
    { icon: $r('app.media.lungs'), title: '呼吸', color: Color.Blue },
    { icon: $r('app.media.activity'), title: '活动能力', color: Color.Orange },
    { icon: $r('app.media.fire'), title: '健身记录', color: Color.Orange },
    { icon: $r('app.media.moon_phase'), title: '经期跟踪', color: Color.Pink },
    { icon: $r('app.media.people'), title: '身体测量', color: Purple },
    { icon: $r('app.media.electrocardiogram'), title: '生命体征', color: Color.Red },
    { icon: $r('app.media.bed'), title: '睡眠', color: Turquoise },
    { icon: $r('app.media.ear'), title: '听觉', color: Color.Blue },
    { icon: $r('app.media.brain'), title: '心理健康', color:Turquoise },
    { icon: $r('app.media.heart'), title: '心脏', color: Color.Red },
    { icon: $r('app.media.apple'), title: '营养摄入', color: Color.Green },
    { icon: $r('app.media.medicine'), title: '用药', color: Color.Blue },
    { icon: $r('app.media.symptoms'), title: '症状', color: Purple },
    { icon: $r('app.media.plus'), title: '其他数据', color: Color.Blue },
    { icon: $r('app.media.sheet'), title: '临床文档', color: Color.Blue }
  ]

  @State changeValue: string = ''
  @State submitValue: string = ''
  controller: SearchController = new SearchController()


  
  aboutToAppear() {
    // 初始化过滤后的类别为全部类别
    this.filteredCategories = [...this.healthCategories]
  }
  @State filteredCategories: Array<HealthCategory> = []
  // 过滤健康类别
  filterCategories(keyword: string) {
    if (keyword.trim() === '') {
      // 如果搜索关键词为空，显示所有类别
      this.filteredCategories = [...this.healthCategories]
    } else {
      // 根据关键词过滤类别
      this.filteredCategories = this.healthCategories.filter(item => 
        item.title.includes(keyword)
      )
    }
  }

  @Builder
  SearchBar() {
    Row() {
      Column(){
       
        Search({ value: this.changeValue, placeholder: '搜索', controller: this.controller })
          .searchIcon({
            size: '16vp',
            color: '#99000000',
            src: $r('app.media.search')
          })
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .textFont({ size: 14, weight: 400 })
          .onSubmit((value: string) => {
            this.submitValue = value
            this.filterCategories(value)
          })
          .onChange((value: string) => {
            this.changeValue = value
            this.filterCategories(value)
          })
          .onTouch((event) => {
            if (event.type === TouchType.Down) {
              this.controller.stopEditing()
            }
          })

      }



    }
    .width('100%')
    .margin({ top: 10, bottom: 20 })
  }

    // 跳转到详情页
  navigateToCategoryDetail(category: HealthCategory) {
    router.pushUrl({
      url: 'pages/CategoryDetailPage',
      params: {
        title: category.title,

      }
    });
  }

  @Builder
  CategoryItem(icon: Resource, title: string, color: ResourceColor) {
    Row() {
      Row() {
        Image(icon)
          .width(30)
          .height(30)
          .margin({left:20, right: 10,top:4,bottom:4 })
          .colorBlend(color)
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(VerticalAlign.Center)
      
      Image($r('app.media.right'))
        .width(16)
        .height(16)
        .colorBlend("#c4c5c7")
        .margin({ right:20 })

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      // 获取对应的类别对象
      const categoryObj = this.healthCategories.find(item => item.title === title);
      if (categoryObj) {
        this.navigateToCategoryDetail(categoryObj);
      }
    })
  }

  build() {

    List() {
      ListItem(){
        Row() {
          Text("浏览")
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
          Image($r("app.media.profile"))
            .height(35)
            .borderRadius(35)

        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .padding({ top: 15, bottom: 10 })
      }

      ListItem() {
        this.SearchBar()
      }

      if (this.filteredCategories.length === 0) {
        ListItem() {
          Column() {
            Image($r('app.media.search'))
              .width(50)
              .height(50)
              .opacity(0.5)
              .margin({ top: 50, bottom: 20 })
            Text('未找到相关健康类别')
              .fontSize(16)
              .fontColor(Color.Gray)
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      } else {
        ListItem() {
          Text("健康类别")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 10 })
        }

        ForEach(this.filteredCategories, (item: HealthCategory, index: number) => {
          ListItem() {
            this.CategoryItem(item.icon, item.title, item.color)
          }
          .backgroundColor(Color.White)
          .borderRadius(index === 0 ? { topLeft: 10, topRight: 10 } :
                        index === this.filteredCategories.length - 1 ? { bottomLeft: 10, bottomRight: 10 } : 0)

          if (index !== this.filteredCategories.length - 1) {
            ListItem() {
              Divider()
                .strokeWidth(1)
                .color('#e0e0e1')
                .margin({ left: 57 })
                .borderColor(Color.Transparent)
                .backgroundColor(Color.Transparent)
            }.height(1)
            .backgroundColor(Color.White)
          }
        })
      }
    }
    .backgroundColor('#f1f2f6')
    .padding({ left: 20, right: 20 })
  }
}