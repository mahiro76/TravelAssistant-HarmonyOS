import { notificationManager } from '@kit.NotificationKit';
import { Constants } from '../common/Constants';

export class NotificationService {
  private static instance: NotificationService;

  private constructor() {
  }

  static getInstance(): NotificationService {
    if (NotificationService.instance == null) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async initNotificationChannel(context: Context): Promise<void> {
    try {
      await notificationManager.addSlot(notificationManager.SlotType.SOCIAL_COMMUNICATION);
    } catch (err) {
      console.error('创建通知渠道失败: ' + JSON.stringify(err));
    }
  }

  async sendArrivalReminder(
    context: Context,
    routeName: string,
    stationName: string,
    plateNumber: string
  ): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Constants.NOTIFICATION_REMINDER_ID,
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '🚌 到站提醒',
            text: `您乘坐的${routeName}即将到达${stationName}（车牌: ${plateNumber}）`,
            additionalText: '请准备下车'
          }
        } as notificationManager.NotificationContent,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION as number,
        deliveryTime: new Date().getTime(),
        showDeliveryTime: true,
        wantAgent: {
          pkgName: Constants.BUNDLE_NAME,
          abilityName: 'EntryAbility',
          parameters: {
            'action': Constants.ACTION_VIEW_REMINDER
          }
        }
      };
      await notificationManager.publish(notificationRequest);
    } catch (err) {
      console.error('发送通知失败: ' + JSON.stringify(err));
    }
  }

  async cancelArrivalReminder(): Promise<void> {
    try {
      await notificationManager.cancel(Constants.NOTIFICATION_REMINDER_ID);
    } catch (err) {
      console.error('取消通知失败: ' + JSON.stringify(err));
    }
  }
}
