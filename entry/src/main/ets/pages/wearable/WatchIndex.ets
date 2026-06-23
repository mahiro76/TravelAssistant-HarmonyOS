  import { router } from '@kit.ArkUI';
import { DatabaseHelper } from '../../database/DatabaseHelper';
import { FavoriteRoute } from '../../model/FavoriteData';
import { ReminderInfo } from '../../model/FavoriteData';

@Entry
@Component
struct WatchIndex {
  @State currentTab: number = 0;
  @State favorites: FavoriteRoute[] = [];
  @State reminders: ReminderInfo[] = [];
  @State isLoading: boolean = true;

  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    const context = getContext(this);
    await this.dbHelper.init(context);
    this.favorites = await this.dbHelper.getAllFavorites();
    this.reminders = await this.dbHelper.getAllReminders();
    this.isLoading = false;
  }

  syncFromPhone(): void {
    this.loadData();
  }

  build() {
    Column() {
      // 手表端顶部
      Row() {
        Text('⌚')
          .fontSize(18)
        Text('出行助手')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 6 })
        Blank()
        Text('🔄')
          .fontSize(16)
          .onClick(() => {
            this.syncFromPhone();
          })
      }
      .width('100%')
      .padding(12)

      // 标签切换
      Row() {
        Column() {
          Text('收藏路线')
            .fontSize(12)
            .fontColor(this.currentTab === 0 ? '#0078D4' : '#888888')
            .fontWeight(this.currentTab === 0 ? FontWeight.Medium : FontWeight.Regular)
          if (this.currentTab === 0) {
            Divider()
              .width('100%')
              .color('#0078D4')
              .height(2)
          }
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 0;
        })

        Column() {
          Text('到站提醒')
            .fontSize(12)
            .fontColor(this.currentTab === 1 ? '#0078D4' : '#888888')
            .fontWeight(this.currentTab === 1 ? FontWeight.Medium : FontWeight.Regular)
          if (this.currentTab === 1) {
            Divider()
              .width('100%')
              .color('#0078D4')
              .height(2)
          }
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 1;
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(24)
            .height(24)
        }
        .width('100%')
        .margin({ top: 40 })
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      } else if (this.currentTab === 0) {
        // 收藏路线列表（手表端精简显示）
        if (this.favorites.length === 0) {
          Column() {
            Text('暂无收藏路线')
              .fontSize(13)
              .fontColor('#999999')
            Text('请在手机端添加收藏')
              .fontSize(11)
              .fontColor('#BBBBBB')
              .margin({ top: 4 })
          }
          .width('100%')
          .margin({ top: 40 })
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
        } else {
          Scroll() {
            Column() {
              ForEach(this.favorites, (favorite: FavoriteRoute, index: number) => {
                Row() {
                  Text(favorite.routeType === '地铁' ? '🚇' : '🚍')
                    .fontSize(16)
                  Column() {
                    Text(favorite.routeName)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                    Text(favorite.startStation + '→' + favorite.endStation)
                      .fontSize(10)
                      .fontColor('#888888')
                      .margin({ top: 2 })
                  }
                  .margin({ left: 8 })
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ top: index > 0 ? 6 : 0 })
                .shadow({ radius: 2, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
              }, (favorite: FavoriteRoute) => favorite.id.toString())
            }
            .width('100%')
            .padding(12)
          }
          .layoutWeight(1)
        }
      } else {
        // 到站提醒列表（手表端精简显示）
        if (this.reminders.length === 0) {
          Column() {
            Text('暂无到站提醒')
              .fontSize(13)
              .fontColor('#999999')
            Text('请在手机端添加提醒')
              .fontSize(11)
              .fontColor('#BBBBBB')
              .margin({ top: 4 })
          }
          .width('100%')
          .margin({ top: 40 })
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
        } else {
          Scroll() {
            Column() {
              ForEach(this.reminders, (reminder: ReminderInfo, index: number) => {
                Row() {
                  Text('🔔')
                    .fontSize(14)
                  Column() {
                    Text(reminder.routeName)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                    Text(reminder.stationName + ' · ' + reminder.direction)
                      .fontSize(10)
                      .fontColor('#888888')
                      .margin({ top: 2 })
                  }
                  .margin({ left: 6 })
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                  Text(reminder.isEnabled ? 'ON' : 'OFF')
                    .fontSize(10)
                    .fontColor(reminder.isEnabled ? '#107C10' : '#CCCCCC')
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ top: index > 0 ? 6 : 0 })
                .shadow({ radius: 2, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
              }, (reminder: ReminderInfo) => reminder.id.toString())
            }
            .width('100%')
            .padding(12)
          }
          .layoutWeight(1)
        }
      }

      // 底部同步提示
      Text('数据与手机端同步')
        .fontSize(10)
        .fontColor('#AAAAAA')
        .padding({ bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
