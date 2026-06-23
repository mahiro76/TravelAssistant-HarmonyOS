import { router } from '@kit.ArkUI';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { FavoriteRoute } from '../model/FavoriteData';
import { BusDataService } from '../service/BusDataService';

@Entry
@Component
struct Favorites {
  @State favorites: FavoriteRoute[] = [];
  @State isLoading: boolean = true;

  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  aboutToAppear(): void {
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    this.isLoading = true;
    const context = getContext(this);
    await this.dbHelper.init(context);
    this.favorites = await this.dbHelper.getAllFavorites();
    this.isLoading = false;
  }

  async removeFavorite(id: number): Promise<void> {
    await this.dbHelper.removeFavorite(id);
    this.loadFavorites();
  }

  viewRoute(routeId: string): void {
    router.pushUrl({
      url: 'pages/RouteSearch',
      params: { routeId: routeId }
    });
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return date.getFullYear() + '-' +
      (date.getMonth() + 1).toString().padStart(2, '0') + '-' +
      date.getDate().toString().padStart(2, '0') + ' ' +
      date.getHours().toString().padStart(2, '0') + ':' +
      date.getMinutes().toString().padStart(2, '0');
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
        Text('收藏路线')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
        Text('管理')
          .fontSize(14)
          .fontColor('#0078D4')
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
      } else if (this.favorites.length === 0) {
        Column() {
          Text('⭐')
            .fontSize(48)
          Text('还没有收藏路线')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text('在路线查询页面中收藏常用路线')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ top: 8 })
          Button() {
            Text('去查询路线')
              .fontSize(14)
          }
          .backgroundColor('#0078D4')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .height(40)
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/RouteSearch' });
          })
        }
        .width('100%')
        .margin({ top: 80 })
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      } else {
        Scroll() {
          Column() {
            Text('共 ' + this.favorites.length + ' 条收藏路线')
              .fontSize(13)
              .fontColor('#888888')
              .width('100%')
              .padding({ left: 4, bottom: 8 })

            ForEach(this.favorites, (favorite: FavoriteRoute, index: number) => {
              Column() {
                Row() {
                  Text(favorite.routeType === '地铁' ? '🚇' : '🚍')
                    .fontSize(24)
                  Column() {
                    Text(favorite.routeName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(favorite.startStation + ' → ' + favorite.endStation)
                      .fontSize(13)
                      .fontColor('#888888')
                      .margin({ top: 3 })
                    Text('收藏于 ' + this.formatDate(favorite.createTime))
                      .fontSize(11)
                      .fontColor('#AAAAAA')
                      .margin({ top: 2 })
                  }
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 操作按钮
                  Button() {
                    Text('查看')
                      .fontSize(12)
                  }
                  .backgroundColor('#0078D4')
                  .fontColor('#FFFFFF')
                  .borderRadius(6)
                  .height(30)
                  .margin({ right: 6 })
                  .onClick(() => {
                    this.viewRoute(favorite.routeId);
                  })

                  Button() {
                    Text('✕')
                      .fontSize(14)
                  }
                  .backgroundColor('#FFF0F0')
                  .fontColor('#E81224')
                  .borderRadius(6)
                  .height(30)
                  .width(30)
                  .onClick(() => {
                    this.removeFavorite(favorite.id);
                  })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .padding(14)
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .margin({ top: index > 0 ? 8 : 0 })
              .shadow({ radius: 3, offsetY: 1, color: 'rgba(0,0,0,0.06)' })
            }, (favorite: FavoriteRoute) => favorite.id.toString())
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
