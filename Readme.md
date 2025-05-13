# AppleHealth 健康应用

<!-- TOC -->
## 目录
- [AppleHealth 健康应用](#applehealth-健康应用)
  - [目录](#目录)
  - [1.项目概述](#1项目概述)
    - [1.1.项目简介](#11项目简介)
    - [1.2. 目标](#12-目标)
    - [1.3.技术路线](#13技术路线)
  - [2.功能特性](#2功能特性)
  - [3.技术架构](#3技术架构)
  - [4.页面功能及其跳转逻辑](#4页面功能及其跳转逻辑)
    - [4.1.页面功能](#41页面功能)
      - [功能与页面映射表](#功能与页面映射表)
  - [5.健康数据管理](#5健康数据管理)
  - [6.权限管理机制](#6权限管理机制)
  - [7.特色功能实现](#7特色功能实现)
    - [健康提醒系统](#健康提醒系统)
    - [趋势分析图表](#趋势分析图表)
  - [8.本地化适配](#8本地化适配)
  - [9.开发指南](#9开发指南)
    - [环境要求](#环境要求)
    - [数据模拟](#数据模拟)
  - [许可证](#许可证)
<!-- TOC -->



## 1.项目概述

### 1.1.项目简介
本文档描述了一个基于HarmonyOS的健康追踪应用，其设计灵感来源于苹果的“健康”软件，但增加了额外的功能。

### 1.2. 目标
本项目旨在为用户提供与苹果“健康”应用相似的体验。通过1：1复刻核心界面和功能，同时增加创新功能，如健康提醒、趋势分析等，提升用户交互和数据管理能力。

### 1.3.技术路线
本项目采用组件化架构，结合HarmonyOS的传感器、和UI组件，实现了实时健康数据追踪、分享和个性化设置，并且利用其原生 API 实现实时数据跟踪和安全的数据管理。应用基于 HarmonyOS ArkUI（方舟UI） 框架开发，使用 ETS 语言，集成了传感器、位置服务和通知等功能。数据通过 `AppStorage` 持久化存储，UI 采用响应式状态管理。

## 2.功能特性
- 原生功能复刻：
  - **仪表板**：健康数据看板，展示关键健康指标，如步数、活动能量、身高、体重、BMI 和爬楼层数。
  - **分类浏览**：用户可以浏览不同的健康分类，如呼吸、心脏等。
  - 健康数据的总结性展示（如每日摘要）
  - 详细查看特定健康指标（如步数、活跃能量、BMI等）
  - 临床文档管理
  - 研究数据共享UI
  - 健康信息收集向导
  - 浏览和搜索不同健康类别
  - 健康数据的分享和请求功能UI
  - 用户信息收集和通知设置
- 创新功能扩展：
  - 实时健康状态提醒
  - 健康数据同步
  - BMI计算与同步

## 3.技术架构
A. 架构
基于HarmonyOS的ETS（Extended TypeScript）语言开发。
采用组件化架构，每个页面或功能模块独立为一个组件（如AbstractPage.ets、SharePage.ets等）。
主入口为Index.ets，负责初始化数据、验证用户信息并管理主导航。
- ArkUI声明式开发范式
- MVVM数据驱动架构
- AppStorage全局状态管理
- PersistentStorage数据持久化
- 传感器服务集成：
  - 计步器(Pedometer)
  - 加速度传感器
  - 位置服务



## 4.页面功能及其跳转逻辑

### 4.1.页面功能
#### 功能与页面映射表
以下表格总结了应用的主要功能及其对应的页面：
| 功能           | 页面               | 描述                             |
| -------------- | ------------------ | -------------------------------- |
| 健康指标仪表板 | AbstractPage       | 显示实时健康指标和历史趋势       |
| 分类浏览       | BrowsePage         | 浏览健康分类，支持搜索和过滤     |
| 分类详情       | CategoryDetailPage | 显示分类下的具体指标             |
| 指标详情       | DetailPage         | 提供单个指标的详细信息和数据录入 |
| 数据共享       | SharePage          | 管理健康数据共享和权限           |
| 研究权限管理   | ResearchPage       | 管理研究机构数据访问（占位）     |
| 用户数据收集   | UserInfoCollect    | 引导用户录入个人信息             |
| 主导航         | Index              | 提供选项卡导航和用户信息检查     |
| 通用页面模板   | AppPage            | 提供返回按钮和动态标题的页面模板 |




## 5.健康数据管理
- HealthDataStore单例模式
- 健康指标计算逻辑：
```ets:entry/src/main/ets/pages/DetailPage.ets
// 健康指标极值计算逻辑
let minValue = Number.MAX_VALUE;
let maxValue = Number.MIN_VALUE;
// ...数据遍历计算逻辑
```

## 6.权限管理机制
采用分级权限控制：
```ets:entry/src/main/ets/common/utils/ActivityManager.ets
// 动态权限申请实现
public reqPermissionsFromUser(permissions: Array<Permissions>) {
  atManager.requestPermissionsFromUser(context, permissions)
  // ...
}
```

## 7.特色功能实现
### 健康提醒系统
```ets:entry/src/main/ets/pages/UserInfoCollect.ets
// 创建健康提醒
reminderAgentManager.publishReminder(healthReminder)
  .then((reminderId: number) => {
    AppStorage.setOrCreate(\'healthReminderId\', reminderId);
  })
```

### 趋势分析图表
```ets:entry/src/main/ets/pages/AbstractPage.ets
// 柱状图组件实现
this.HistogramChart("steps");
this.HistogramChart("activeEnergy");
```

## 8.本地化适配
- 多语言支持（中/英）
- 单位智能转换（公制/英制）
- 区域化时间格式

## 9.开发指南
### 环境要求
- DevEco Studio 3.1+
- SDK API 9+

### 数据模拟
```ets:entry/src/main/ets/pages/Index.ets
// 初始化模拟数据
PersistentStorage.persistProp(\'todaySteps\', 624);
PersistentStorage.persistProp(\'todayBMI\', 21.8);
```

## 许可证
