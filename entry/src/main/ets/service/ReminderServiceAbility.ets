import { AppServiceExtensionAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { commonEventManager } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';
import { NotificationService } from './NotificationService';
import { DatabaseHelper } from '../database/DatabaseHelper';

export default class ReminderServiceAbility extends AppServiceExtensionAbility {
  private notificationService: NotificationService = NotificationService.getInstance();
  private subscriberId: number = 0;

  onCreate(want: Want): void {
    console.info('ReminderServiceAbility onCreate');
    this.subscribeReminderEvent();
  }

  onRequest(want: Want, startId: number): void {
    console.info('ReminderServiceAbility onRequest, startId: ' + startId);
  }

  onDestroy(): void {
    console.info('ReminderServiceAbility onDestroy');
    this.unsubscribeReminderEvent();
  }

  private subscribeReminderEvent(): void {
    try {
      const subscriberInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [Constants.EVENT_REMINDER_ARRIVAL]
      };
      commonEventManager.createSubscriber(subscriberInfo).then((subscriber) => {
        commonEventManager.subscribe(subscriber, (err: BusinessError, data: commonEventManager.CommonEventData) => {
          if (err.code !== 0) {
            console.error('订阅公共事件失败: ' + JSON.stringify(err));
            return;
          }
          this.handleReminderEvent(data);
        });
        this.subscriberId = 1;
        console.info('订阅到站提醒事件成功');
      }).catch((err: Error) => {
        console.error('创建订阅者失败: ' + JSON.stringify(err));
      });
    } catch (err) {
      console.error('订阅到站提醒事件异常: ' + JSON.stringify(err));
    }
  }

  private unsubscribeReminderEvent(): void {
    try {
      if (this.subscriberId !== 0) {
        console.info('取消订阅到站提醒事件');
      }
    } catch (err) {
      console.error('取消订阅失败: ' + JSON.stringify(err));
    }
  }

  private handleReminderEvent(data: commonEventManager.CommonEventData): void {
    try {
      const dataStr: string = typeof data.data === 'string' ? data.data : '';
      if (dataStr) {
        const reminderData: Record<string, string> = JSON.parse(dataStr);
        const routeName: string = reminderData.routeName || '未知线路';
        const stationName: string = reminderData.stationName || '未知站点';
        const plateNumber: string = reminderData.plateNumber || '未知';
        console.info(`到站提醒: ${routeName} 即将到达 ${stationName}`);

        this.notificationService.sendArrivalReminder(
          this.context, routeName, stationName, plateNumber
        );
      }
    } catch (err) {
      console.error('处理提醒事件失败: ' + JSON.stringify(err));
    }
  }
}
