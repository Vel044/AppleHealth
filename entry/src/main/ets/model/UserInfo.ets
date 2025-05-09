// model/UserInfo.ets
export interface UserInfo {
  surName: string;
  givenName:string
  birthday: Date;
  gender: string;
  userHeight: number;
  weight: number;
  notificationAllowed: boolean; // 新增通知权限状态
}

export const defaultUserInfo: UserInfo = {
  surName: 'Vel',
  givenName:"Sensei",
  birthday: new Date(),
  gender: '男',
  userHeight: 173,
  weight: 65.5,
  notificationAllowed: false
}