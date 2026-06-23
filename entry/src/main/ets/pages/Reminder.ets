import { router } from '@kit.ArkUI';
import { commonEventManager, BusinessError } from '@kit.BasicServicesKit';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { ReminderInfo } from '../model/FavoriteData';
import { BusDataService } from '../service/BusDataService';
import { NotificationService } from '../service/NotificationService';
import { Constants } from '../common/Constants';

interface EventData {
  routeName: string;
  stationName: string;
  plateNumber: string;
  routeId: string;
}

@Entry
@Component
struct Reminder {
  @State reminders: ReminderInfo[] = [];
  @State isLoading: boolean = true;
  @State showCreateDialog: boolean = false;

  // 新建提醒表单
  @State newRouteId: string = '';
  @State newRouteName: string = '';
  @State newStationName: string = '';
  @State newDirection: string = '上行';
  @State newRemindStops: number = 1;

  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private busService: BusDataService = BusDataService.getInstance();
  private notifyService: NotificationService = NotificationService.getInstance();

  aboutToAppear(): void {
    this.loadReminders();
    this.initNotification();
  }

  async initNotification(): Promise<void> {
    const context = getContext(this);
    await this.notifyService.initNotificationChannel(context);
  }

  async loadReminders(): Promise<void> {
    this.isLoading = true;
    const context = getContext(this);
    await this.dbHelper.init(context);
    this.reminders = await this.dbHelper.getAllReminders();
    this.isLoading = false;
  }

  async removeReminder(id: number): Promise<void> {
    await this.dbHelper.removeReminder(id);
    this.loadReminders();
  }

  async toggleReminder(id: number, isEnabled: boolean): Promise<void> {
    await this.dbHelper.updateReminderStatus(id, isEnabled);
    this.loadReminders();
  }

  async simulateArrival(reminder: ReminderInfo): Promise<void> {
    const context = getContext(this);
    const plateNumber = '京A·' + (Math.floor(Math.random() * 90000) + 10000);
    await this.notifyService.sendArrivalReminder(context, reminder.routeName, reminder.stationName, plateNumber);

    // 发送公共事件
    const eventData = {
      routeName: reminder.routeName,
      stationName: reminder.stationName,
      plateNumber: plateNumber,
      routeId: reminder.routeId
    } as EventData;
    try {
      commonEventManager.publish(Constants.EVENT_REMINDER_ARRIVAL, {
        data: JSON.stringify(eventData),
        isOrdered: false
      }, (err: BusinessError) => {
        if (err) {
          console.error('发送到站公共事件失败: ' + JSON.stringify(err));
        }
      });
    } catch (err) {
      console.error('发送到站公共事件失败: ' + JSON.stringify(err));
    }
  }

  async createReminder(): Promise<void> {
    if (!this.newRouteName || !this.newStationName) {
      return;
    }
    const reminder = new ReminderInfo(
      0,
      this.newRouteId,
      this.newRouteName,
      '',
      this.newStationName,
      this.newDirection,
      this.newRemindStops,
      true,
      Date.now()
    );
    await this.dbHelper.addReminder(reminder);
    this.showCreateDialog = false;
    this.newRouteName = '';
    this.newStationName = '';
    this.newRouteId = '';
    this.newRemindStops = 1;
    this.loadReminders();
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Text('←')
          .fontSize(20)
          .onClick(() => {
            router.back();
          })
        Text('到站提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
        Button() {
          Text('+ 新建')
            .fontSize(13)
        }
        .backgroundColor('#0078D4')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .height(34)
        .onClick(() => {
          this.showCreateDialog = true;
        })
      }
      .width('100%')
      .padding(16)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
        }
        .width('100%')
        .margin({ top: 100 })
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      } else if (this.reminders.length === 0) {
        Column() {
          Text('🔔')
            .fontSize(48)
          Text('暂无到站提醒')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text('添加提醒后，到站时会震动+铃声通知')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ top: 8 })
          Button() {
            Text('添加提醒')
              .fontSize(14)
          }
          .backgroundColor('#0078D4')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .height(40)
          .margin({ top: 20 })
          .onClick(() => {
            this.showCreateDialog = true;
          })
        }
        .width('100%')
        .margin({ top: 80 })
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      } else {
        Scroll() {
          Column() {
            Text('共 ' + this.reminders.length + ' 条提醒')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 8 })

            ForEach(this.reminders, (reminder: ReminderInfo, index: number) => {
              Column() {
                Row() {
                  Column() {
                    Text('🔔')
                      .fontSize(20)
                  }
                  .width(36)

                  Column() {
                    Text(reminder.routeName + ' · ' + reminder.stationName)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                    Row() {
                      Text(reminder.direction + '方向')
                        .fontSize(12)
                        .fontColor('#888888')
                      Text('提前' + reminder.remindBeforeStops + '站提醒')
                        .fontSize(12)
                        .fontColor('#888888')
                        .margin({ left: 8 })
                    }
                    .margin({ top: 3 })
                  }
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Toggle({ type: ToggleType.Switch, isOn: reminder.isEnabled })
                    .onChange((isOn: boolean) => {
                      this.toggleReminder(reminder.id, isOn);
                    })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .padding(14)

                Row() {
                  Button() {
                    Text('模拟到站')
                      .fontSize(12)
                  }
                  .backgroundColor('#E8F5E9')
                  .fontColor('#107C10')
                  .borderRadius(6)
                  .height(30)
                  .onClick(() => {
                    this.simulateArrival(reminder);
                  })

                  Blank()

                  Button() {
                    Text('删除')
                      .fontSize(12)
                  }
                  .backgroundColor('#FFF0F0')
                  .fontColor('#E81224')
                  .borderRadius(6)
                  .height(30)
                  .onClick(() => {
                    this.removeReminder(reminder.id);
                  })
                }
                .width('100%')
                .padding({ left: 60, right: 14, bottom: 10 })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .margin({ top: index > 0 ? 8 : 0 })
              .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
            }, (reminder: ReminderInfo) => reminder.id.toString())
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }

      // 新建提醒弹窗
      if (this.showCreateDialog) {
        Column() {
          Column() {
            Text('新建到站提醒')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .padding({ bottom: 16 })

            TextInput({ placeholder: '请输入线路名称（如：1路）' })
              .height(40)
              .onChange((value: string) => {
                this.newRouteName = value;
                this.newRouteId = value;
              })

            TextInput({ placeholder: '请输入目标站点名称' })
              .height(40)
              .margin({ top: 10 })
              .onChange((value: string) => {
                this.newStationName = value;
              })

            Row() {
              Text('方向: ')
                .fontSize(14)
              Row() {
                Button(this.newDirection === '上行' ? '▸ 上行' : '上行')
                  .backgroundColor(this.newDirection === '上行' ? '#0078D4' : '#F0F0F0')
                  .fontColor(this.newDirection === '上行' ? '#FFFFFF' : '#666666')
                  .borderRadius(6)
                  .height(34)
                  .onClick(() => {
                    this.newDirection = '上行';
                  })
                Button(this.newDirection === '下行' ? '▸ 下行' : '下行')
                  .backgroundColor(this.newDirection === '下行' ? '#0078D4' : '#F0F0F0')
                  .fontColor(this.newDirection === '下行' ? '#FFFFFF' : '#666666')
                  .borderRadius(6)
                  .height(34)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.newDirection = '下行';
                  })
              }
            }
            .width('100%')
            .margin({ top: 10 })

            Row() {
              Text('提前提醒: ')
                .fontSize(14)
              Slider({
                value: this.newRemindStops,
                min: 0,
                max: 5,
                step: 1
              })
              .width(120)
              .onChange((value: number) => {
                this.newRemindStops = value;
              })
              Text(this.newRemindStops + '站')
                .fontSize(13)
                .fontColor('#0078D4')
                .margin({ left: 8 })
            }
            .width('100%')
            .margin({ top: 10 })

            Row() {
              Button('取消')
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .borderRadius(8)
                .height(40)
                .layoutWeight(1)
                .onClick(() => {
                  this.showCreateDialog = false;
                })
              Button('确认添加')
                .backgroundColor('#0078D4')
                .fontColor('#FFFFFF')
                .borderRadius(8)
                .height(40)
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => {
                  this.createReminder();
                })
            }
            .width('100%')
            .margin({ top: 20 })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding(20)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 0 })
        .onClick(() => {
          this.showCreateDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
