// pages/CategoryDetailPage.ets


import router from '@ohos.router'

interface  RouTmp{
  title:string

}

@Entry
@Component
struct CategoryDetailPage {

  params: RouTmp = router.getParams() as RouTmp;
  @State title: string = this.params.title;

  
  // 呼吸相关指标数据
  private respiratoryMetrics: Array<HealthMetric> = [];
  
  aboutToAppear() {
    // 根据不同类别加载不同的指标
    if (this.title === '呼吸') {
      this.respiratoryMetrics = [
        { title: '有氧适能', value: '0', unit: '最大摄氧量', date: '2019年2月', hasData: true },
        { title: '第一秒用力呼气量', value: '', unit: '', date: '', hasData: false },
        { title: '呼气流量峰值', value: '', unit: '', date: '', hasData: false },
        { title: '呼吸频率', value: '', unit: '', date: '', hasData: false },
        { title: '呼吸紊乱', value: '', unit: '', date: '', hasData: false },
        { title: '六分钟步行', value: '', unit: '', date: '', hasData: false },
        { title: '睡眠呼吸暂停通知', value: '', unit: '', date: '', hasData: false },
        { title: '吸入剂用量', value: '', unit: '', date: '', hasData: false }
      ]
    }
    // 可以根据不同的title加载不同的数据
  }
  
  // 返回按钮
  @Builder
  BackButton() {
    Row() {
      Image($r('app.media.left'))
        .width(24)
        .height(24)
        .margin({ right: 16 })
        .onClick(() => {
          router.back();
        })
      
      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding({ left: 20, top: 20, bottom: 10 })
  }
  
  // 数据项构建器
  @Builder
  MetricItem(metric: HealthMetric) {
    Column() {
      if (metric.hasData) {
        Row() {
          Row() {
            Image($r('app.media.heart'))
              .width(20)
              .height(20)
              .margin({ right: 10 })
            Text(metric.title)
              .fontSize(16)
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(VerticalAlign.Center)
          
          Text(metric.date)
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        
        Row() {
          Text(metric.value)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
          Text(metric.unit)
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ left: 8, bottom: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16, bottom: 12 })
      } else {
        Row() {
          Text(metric.title)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            
          Image($r('app.media.right'))
            .width(16)
            .height(16)
            .colorBlend("#c4c5c7")
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }
    }
    .backgroundColor(Color.White)
    .borderRadius(metric.title === this.respiratoryMetrics[0].title ? { topLeft: 10, topRight: 10 } :
                metric.title === this.respiratoryMetrics[this.respiratoryMetrics.length - 1].title ? 
                { bottomLeft: 10, bottomRight: 10 } : 0)
  }
  
  build() {
    Column() {
      // 返回导航
      this.BackButton()
      
      // 更早计步器
      Text("更早")
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, top: 20, bottom: 10 })
      
      // 数据列表
      List() {
        ForEach(this.respiratoryMetrics, (metric: HealthMetric, index) => {
          ListItem() {
            this.MetricItem(metric)
          }
          
          if (index < this.respiratoryMetrics.length - 1) {
            ListItem() {
              Divider()
                .strokeWidth(1)
                .color('#e0e0e1')
                .margin({ left: 16 })
            }
            .backgroundColor(Color.White)
          }
        })
      }
      .backgroundColor('#f1f2f6')
      .margin({ left: 20, right: 20 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f2f6')
  }
}

// 健康指标接口
interface HealthMetric {
  title: string,
  value: string,
  unit: string,
  date: string,
  hasData: boolean
}