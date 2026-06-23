import { router } from '@kit.ArkUI';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { PreferencesHelper } from '../database/PreferencesHelper';

@Entry
@Component
struct Index {
  @State currentTime: string = '';
  @State greetingText: string = '';

  private timerId: number = -1;

  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private prefHelper: PreferencesHelper = PreferencesHelper.getInstance();

  aboutToAppear(): void {
    this.updateTime();
    this.startTimer();
    this.initDatabase();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  async initDatabase(): Promise<void> {
    const context = getContext(this);
    await this.dbHelper.init(context);
    await this.prefHelper.init(context);
  }

  updateTime(): void {
    const now = new Date();
    const hours = now.getHours();
    const minutes = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}`;
    if (hours >= 5 && hours < 12) {
      this.greetingText = '早上好';
    } else if (hours >= 12 && hours < 14) {
      this.greetingText = '中午好';
    } else if (hours >= 14 && hours < 18) {
      this.greetingText = '下午好';
    } else {
      this.greetingText = '晚上好';
    }
  }

  startTimer(): void {
    this.timerId = setInterval(() => {
      this.updateTime();
    }, 60000);
  }

  stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  navigateTo(page: string): void {
    router.pushUrl({ url: page });
  }

  @Builder
  navCard(icon: string, title: string, desc: string, targetPage: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(28)
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
        Column() {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
          Text(desc)
            .fontSize(12)
            .fontColor('#666666')
            .lineHeight(18)
            .margin({ top: 2 })
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .padding(16)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 4,
      offsetX: 0,
      offsetY: 2,
      color: 'rgba(0, 0, 0, 0.08)'
    })
    .onClick(() => {
      this.navigateTo(targetPage);
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Column() {
          Text(this.greetingText)
            .fontSize(14)
            .fontColor('#999999')
          Text('便民出行助手')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.currentTime)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0078D4')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16 })

      // 欢迎标语
      Text('您的一站式出行管家，查公交、查地铁、到站提醒一应俱全')
        .fontSize(13)
        .fontColor('#888888')
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })
        .lineHeight(18)

      // 功能导航卡片
      Scroll() {
        Column() {
          // 第一行 - 查询功能
          Row() {
            this.navCard('🚍', '公交查询', '查询公交线路和实时到站', 'pages/RouteSearch')
            this.navCard('🚇', '地铁查询', '查询地铁线路信息', 'pages/RouteSearch')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          Row() {
            this.navCard('📍', '站点查询', '搜索公交/地铁站点', 'pages/StationSearch')
            this.navCard('⏱️', '实时到站', '查看车辆实时到站预测', 'pages/ArrivalPrediction')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })

          // 第二行 - 管理与设置
          Row() {
            this.navCard('⭐', '收藏路线', '管理您收藏的常用路线', 'pages/Favorites')
            this.navCard('🔔', '到站提醒', '设置到站震动+铃声提醒', 'pages/Reminder')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })

          Row() {
            this.navCard('⚙️', '设置', '同步、缓存等系统设置', 'pages/Settings')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })

          // 底部信息
          Text('数据来源于模拟数据服务，离线缓存可用')
            .fontSize(12)
            .fontColor('#BBBBBB')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 24, bottom: 24 })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
