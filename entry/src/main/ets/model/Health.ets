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
  recordDate: new Date()
};
