import { router } from '@kit.ArkUI';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { PreferencesHelper } from '../database/PreferencesHelper';
import { BusDataService } from '../service/BusDataService';

@Entry
@Component
struct Settings {
  @State distributeSync: boolean = false;
  @State offlineMode: boolean = false;
  @State notificationEnabled: boolean = true;
  @State themeMode: string = 'light';
  @State cacheCount: number = 0;

  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private prefHelper: PreferencesHelper = PreferencesHelper.getInstance();
  private busService: BusDataService = BusDataService.getInstance();

  aboutToAppear(): void {
    this.loadSettings();
  }

  async loadSettings(): Promise<void> {
    const context = getContext(this);
    await this.dbHelper.init(context);
    await this.prefHelper.init(context);
    this.distributeSync = await this.prefHelper.isDistributeSyncEnabled();
    this.offlineMode = await this.prefHelper.isOfflineModeEnabled();
    this.notificationEnabled = await this.prefHelper.isNotificationEnabled();
    this.themeMode = await this.prefHelper.getThemeMode();

    const cachedRoutes = await this.dbHelper.getCachedRoutes();
    this.cacheCount = cachedRoutes.length;
  }

  async setDistributeSync(value: boolean): Promise<void> {
    this.distributeSync = value;
    await this.prefHelper.setDistributeSyncEnabled(value);
  }

  async setOfflineMode(value: boolean): Promise<void> {
    this.offlineMode = value;
    await this.prefHelper.setOfflineModeEnabled(value);
  }

  async setNotification(value: boolean): Promise<void> {
    this.notificationEnabled = value;
    await this.prefHelper.setNotificationEnabled(value);
  }

  async setTheme(value: string): Promise<void> {
    this.themeMode = value;
    await this.prefHelper.setThemeMode(value);
  }

  async cacheAllData(): Promise<void> {
    await this.busService.cacheAllRoutes();
    const cachedRoutes = await this.dbHelper.getCachedRoutes();
    this.cacheCount = cachedRoutes.length;
  }

  @Builder
  settingItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .width(36)
      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
        Text(desc)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ top: 2 })
      }
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
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
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // 数据同步
          Column() {
            Text('数据同步')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 6 })

            Column() {
              this.settingItem('🔄', '分布式同步', '将收藏路线和提醒同步至鸿蒙手表')
              Row() {
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.distributeSync })
                  .margin({ right: 14 })
                  .onChange((value: boolean) => {
                    this.setDistributeSync(value);
                  })
              }
              .width('100%')
              .height(0)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
          }
          .width('100%')
          .padding({ top: 8 })

          // 缓存管理
          Column() {
            Text('缓存管理')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 6, top: 12 })

            Column() {
              this.settingItem('📴', '离线模式', '无网络时使用缓存数据查看路线')
              Row() {
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.offlineMode })
                  .margin({ right: 14 })
                  .onChange((value: boolean) => {
                    this.setOfflineMode(value);
                  })
              }
              .width('100%')
              .height(0)

              Divider()
                .width('92%')
                .margin({ left: '4%' })

              Row() {
                this.settingItem('💾', '离线缓存数据', '已缓存 ' + this.cacheCount + ' 条路线')
                Blank()
                Button() {
                  Text('缓存全部')
                    .fontSize(12)
                }
                .backgroundColor('#0078D4')
                .fontColor('#FFFFFF')
                .borderRadius(6)
                .height(32)
                .margin({ right: 14 })
                .onClick(() => {
                  this.cacheAllData();
                })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
          }
          .width('100%')

          // 通知设置
          Column() {
            Text('通知与提醒')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 6, top: 12 })

            Column() {
              this.settingItem('🔔', '到站通知', '允许到站时推送震动+铃声提醒')
              Row() {
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
                  .margin({ right: 14 })
                  .onChange((value: boolean) => {
                    this.setNotification(value);
                  })
              }
              .width('100%')
              .height(0)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
          }
          .width('100%')

          // 主题设置
          Column() {
            Text('外观')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 6, top: 12 })

            Column() {
              this.settingItem('🎨', '主题模式', '浅色/深色模式切换')
              Row() {
                Blank()
                Row() {
                  Button('浅色')
                    .backgroundColor(this.themeMode === 'light' ? '#0078D4' : '#F0F0F0')
                    .fontColor(this.themeMode === 'light' ? '#FFFFFF' : '#666666')
                    .borderRadius(6)
                    .height(32)
                    .onClick(() => {
                      this.setTheme('light');
                    })
                  Button('深色')
                    .backgroundColor(this.themeMode === 'dark' ? '#0078D4' : '#F0F0F0')
                    .fontColor(this.themeMode === 'dark' ? '#FFFFFF' : '#666666')
                    .borderRadius(6)
                    .height(32)
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.setTheme('dark');
                    })
                  Button('跟随系统')
                    .backgroundColor(this.themeMode === 'auto' ? '#0078D4' : '#F0F0F0')
                    .fontColor(this.themeMode === 'auto' ? '#FFFFFF' : '#666666')
                    .borderRadius(6)
                    .height(32)
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.setTheme('auto');
                    })
                }
                .margin({ right: 14 })
              }
              .width('100%')
              .padding({ bottom: 14 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
          }
          .width('100%')

          // 应用信息
          Column() {
            Text('应用信息')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 6, top: 12 })

            Column() {
              this.settingItem('📱', '便民出行助手 v1.0.0', '基于 HarmonyOS 开发')
              Divider()
                .width('92%')
                .margin({ left: '4%' })
              Row() {
                this.settingItem('📄', '开源许可', 'MIT License')
                Blank()
                Text('>')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
                  .margin({ right: 14 })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
          }
          .width('100%')

          // 底部间距
          Row()
            .height(40)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
