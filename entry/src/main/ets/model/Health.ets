// model/Health.ets
export interface Health {
  steps: number;                // 当日步数
  activeEnergy: number;         // 活动消耗能量（千卡）
  bmi: number;                 // 身高体重指数（kg/m²）
  flightsClimbed: number;       // 已爬楼层
  heartRate: number;           // 平均心率（次/分钟）
  sleepAnalysis: number;       // 睡眠时长（小时）
  bloodOxygen: number;         // 血氧饱和度（百分比）
  bodyTemperature: number;     // 体温（摄氏度）
  stressLevel: number;         // 压力水平（0-100）
  recordDate: Date;            // 记录日期
  height: number;              // 身高（cm）
  weight: number;              // 体重（kg）
}

export const DefaultHealth:Health = {
  steps: 624,
  activeEnergy: 10.2,
  bmi: 21.8,
  flightsClimbed: 8,
  heartRate: 0,
  sleepAnalysis: 0,
  bloodOxygen: 0,
  bodyTemperature: 0,
  stressLevel: 0,
  recordDate: new Date(),
  height: 173,                 // 默认身高173cm
  weight: 65.5                 // 默认体重65.5kg
};

// 添加历史健康数据存储
@ObservedV2
export class HealthDataStore {
  @Trace public healthHistory: Health[] = [];
  private static _instance: HealthDataStore;

  public static getInstance(): HealthDataStore {
    if (!HealthDataStore._instance) {
      HealthDataStore._instance = new HealthDataStore();
    }
    return HealthDataStore._instance;
  }

  private constructor() {
    // 初始化七天历史数据
    this.healthHistory = this.generatePastWeekData();
  }

  
  public addHealthRecord(record: Health): void {
    this.healthHistory.push(record);
    // 保持最多7天的数据
    if (this.healthHistory.length > 7) {
      this.healthHistory.shift();
    }
  }
  
  // 生成过去七天的模拟数据
  private generatePastWeekData(): Health[] {
    const records: Health[] = [];
    const today = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const recordDate = new Date(today);
      recordDate.setDate(today.getDate() - i);
      
      // 生成一些随机数据作为示例
      const height = 173; // 身高保持不变
      const weight = 65.5 + (Math.random() * 2 - 1); // 体重在64.5-66.5kg之间浮动
      const bmi = Math.round((weight / (height * height / 10000)) * 10) / 10; // 根据身高体重计算BMI
      
      records.push({
        recordDate: recordDate,
        steps: Math.floor(Math.random() * 5000) + 3000, // 3000-8000步
        activeEnergy: Math.floor(Math.random() * 300) + 100, // 100-400千卡
        bmi: bmi, // 使用计算的BMI
        height: height, // 添加身高
        weight: weight, // 添加体重
        flightsClimbed: Math.floor(Math.random() * 10) + 1, // 1-10层
        heartRate: Math.floor(Math.random() * 20) + 60, // 60-80次/分钟
        sleepAnalysis: 6 + Math.random() * 2, // 6-8小时
        bloodOxygen: 95 + Math.random() * 4, // 95-99%
        bodyTemperature: 36.5 + Math.random() * 0.5, // 36.5-37.0°C
        stressLevel: Math.floor(Math.random() * 50) // 0-50
      });
    }
    return records;
  }
}