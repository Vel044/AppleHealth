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
    - [架构与技术栈](#架构与技术栈)
  - [4.页面功能及其跳转逻辑](#4页面功能及其跳转逻辑)
    - [4.1.页面功能](#41页面功能)
      - [功能与页面映射表](#功能与页面映射表)
    - [4.2.页面跳转逻辑](#42页面跳转逻辑)
  - [5.健康数据管理](#5健康数据管理)
  - [6.权限管理机制](#6权限管理机制)
  - [7.特色功能实现](#7特色功能实现)
    - [健康提醒系统](#健康提醒系统)
    - [趋势分析图表](#趋势分析图表)
  - [8.本地化适配](#8本地化适配)
    - [8.1.已实现](#81已实现)
    - [8.2.待实现](#82待实现)
  - [9.开发环境指南](#9开发环境指南)
    - [环境要求](#环境要求)
  - [10.未来计划](#10未来计划)
  - [许可证（MIT Licence）](#许可证mit-licence)
    - [被授权人权利](#被授权人权利)
    - [被授权人义务](#被授权人义务)
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

### 架构与技术栈
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
 **API**：HarmonyOS 原生 API，包括传感器（`@ohos.sensor`）、位置服务（`@ohos.geoLocationManager`）、存储（`AppStorage`）和通知（`notificationManager`）。
 - **实时传感器集成**：通过计步传感器实现步数实时跟踪。
- **持久化存储**：使用 `AppStorage` 保存用户数据和健康指标。
- **响应式状态管理**：通过 `@State` 和 `@Provide` 实现动态 UI 更新。
- **自定义可视化**：为历史数据提供直方图和图表展示。
- **权限管理**：处理传感器、位置和通知权限，确保数据安全。
- **通知系统**：支持健康跟踪提醒，如每日数据录入提示。
- **路由系统**：通过 `router` 模块实现页面间导航（如 `router.pushUrl`、`router.back`）。



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

### 4.2.页面跳转逻辑

```
这边徐娅萍画一张页面跳转逻辑的图
```
应用的导航逻辑基于选项卡和路由系统：
- **主页面（Index）**：提供“摘要”、“共享”和“浏览”选项卡，分别加载 `AbstractPage`、`SharePage` 和 `BrowsePage`。
- **AbstractPage**：点击健康指标跳转至 `DetailPage`，传递指标类型、值和单位。
- **BrowsePage**：选择分类跳转至 `CategoryDetailPage`，传递分类标题。
- **SharePage**：支持跳转至 `AppPage`（应用列表）或 `ResearchPage`（研究管理）。
- **UserInfoCollect**：当用户信息不完整时，作为底部弹窗显示。
- **返回导航**：大多数页面包含返回按钮，使用 `router.back()` 返回上一页。



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

### 8.1.已实现
- 单位智能转换（公制/英制）
- 区域化时间格式
### 8.2.待实现
- 语言本地化
- 布局自适应不同屏幕尺寸

## 9.开发环境指南

### 环境要求
- DevEco Studio 5.0.4
- SDK API 9+

## 10.未来计划

- 完善 `ResearchPage`，添加研究权限管理功能，增加模糊搜索功能。
- 扩展 `BrowsePage` 和 `CategoryDetailPage`，支持更多健康分类和指标。
- 增强数据可视化，引入更复杂的图表类型。（例如苹果“健康”软件中折线图的缩略图/完整图绘制功能）
- 增加一天内/一个月/半年/一年时间跨度的数据展示。
- 优化用户引导流程，增加单位选择等个性化选项。

## 许可证（MIT Licence）

本项目遵循MIT许可证。

### 被授权人权利
被授权人有权利使用、复制、修改、合并、出版发行、散布、再授权及贩售软件及软件的副本。
被授权人可根据程序的需要修改授权条款为适当的内容。

### 被授权人义务
在软件和软件的所有副本中都必须包含版权声明和许可声明。

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 