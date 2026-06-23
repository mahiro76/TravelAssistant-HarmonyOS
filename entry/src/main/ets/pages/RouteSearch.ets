import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { RouteInfo, RouteType } from '../model/RouteData';
import { RouteStation } from '../model/StationData';
import { BusDataService } from '../service/BusDataService';
import { IntentAgentService } from '../service/IntentAgentService';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { FavoriteRoute } from '../model/FavoriteData';

@Entry
@Component
struct RouteSearch {
  @State searchKeyword: string = '';
  @State searchResults: RouteInfo[] = [];
  @State hasSearched: boolean = false;
  @State selectedRoute: RouteInfo | null = null;
  @State routeStations: RouteStation[] = [];
  @State isFavorite: boolean = false;
  @State localFavorites: string[] = [];

  private busService: BusDataService = BusDataService.getInstance();
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private intentService: IntentAgentService = IntentAgentService.getInstance();
  private searchTimerId: number = -1;

  aboutToAppear(): void {
    const context = getContext(this);
    this.dbHelper.init(context);
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    const favorites = await this.dbHelper.getAllFavorites();
    this.localFavorites = favorites.map(f => f.routeId);
  }

  onSearch(value: string): void {
    this.searchKeyword = value;
    if (this.searchTimerId !== -1) {
      clearTimeout(this.searchTimerId);
    }
    this.searchTimerId = setTimeout(() => {
      this.performSearch();
    }, 300);
  }

  async performSearch(): Promise<void> {
    if (this.searchKeyword.trim().length === 0) {
      this.searchResults = [];
      this.hasSearched = false;
      return;
    }
    this.searchResults = await this.busService.searchRoutes(this.searchKeyword.trim());
    this.hasSearched = true;
  }

  async selectRoute(route: RouteInfo): Promise<void> {
    this.selectedRoute = route;
    this.routeStations = await this.busService.getRouteStations(route.routeId);
    this.isFavorite = this.localFavorites.includes(route.routeId);
  }

  async toggleFavorite(): Promise<void> {
    if (this.selectedRoute == null) {
      return;
    }
    const route = this.selectedRoute;
    if (this.isFavorite) {
      await this.dbHelper.removeFavoriteByRouteId(route.routeId);
    } else {
      const favorite = FavoriteRoute.fromRouteInfo(route);
      await this.dbHelper.addFavorite(favorite);
    }
    this.isFavorite = !this.isFavorite;
    await this.loadFavorites();
  }

  async createShortcut(): Promise<void> {
    if (this.selectedRoute == null) {
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    await this.intentService.createRouteShortcut(context, this.selectedRoute.routeId, this.selectedRoute.routeName);
  }

  viewArrivalPrediction(routeId: string): void {
    router.pushUrl({
      url: 'pages/ArrivalPrediction',
      params: { routeId: routeId }
    });
  }

  getRouteTypeIcon(routeType: RouteType): string {
    return routeType === RouteType.BUS ? '🚍' : '🚇';
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        Text('←')
          .fontSize(20)
          .onClick(() => {
            router.back();
          })
        Text('公交/地铁查询')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .padding(16)

      // 搜索输入框
      Row() {
        Search({ value: this.searchKeyword, placeholder: '输入线路名称或编号（如：1路、1号线）' })
          .width('100%')
          .searchButton('搜索')
          .height(44)
          .onChange((value: string) => {
            this.onSearch(value);
          })
          .onSubmit(() => {
            this.performSearch();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      if (this.selectedRoute != null) {
        // 路线详情
        Scroll() {
          Column() {
            // 路线基本信息卡片
            Column() {
              Row() {
                Text(this.getRouteTypeIcon(this.selectedRoute.routeType))
                  .fontSize(32)
                Text(this.selectedRoute.routeName)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 10 })
                Blank()
                Text(this.selectedRoute.routeType)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.selectedRoute.routeType === RouteType.BUS ? '#0078D4' : '#107C10')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(4)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              Row() {
                Column() {
                  Text(this.selectedRoute.startStation)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                  Text('首班: ' + this.selectedRoute.firstBusTime)
                    .fontSize(12)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
                Text('→')
                  .fontSize(18)
                  .fontColor('#0078D4')
                  .margin({ left: 12, right: 12 })
                Column() {
                  Text(this.selectedRoute.endStation)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                  Text('末班: ' + this.selectedRoute.lastBusTime)
                    .fontSize(12)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ top: 12 })

              Row() {
                Text('票价: ¥' + this.selectedRoute.price)
                  .fontSize(13)
                  .fontColor('#666666')
                Blank()
                Text('运营: ' + this.selectedRoute.company)
                  .fontSize(13)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ top: 10 })

              // 操作按钮
              Row() {
                Button() {
                  Row() {
                    Text(this.isFavorite ? '★' : '☆')
                      .fontSize(16)
                    Text(this.isFavorite ? '取消收藏' : '收藏路线')
                      .fontSize(13)
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .backgroundColor(this.isFavorite ? '#FFF3E0' : '#F0F0F0')
                .fontColor(this.isFavorite ? '#FF8C00' : '#666666')
                .borderRadius(8)
                .height(38)
                .onClick(() => {
                  this.toggleFavorite();
                })

                Button() {
                  Row() {
                    Text('🔗')
                      .fontSize(16)
                    Text('桌面快捷')
                      .fontSize(13)
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .borderRadius(8)
                .height(38)
                .margin({ left: 10 })
                .onClick(() => {
                  this.createShortcut();
                })

                Button() {
                  Text('实时到站')
                    .fontSize(13)
                }
                .backgroundColor('#0078D4')
                .fontColor('#FFFFFF')
                .borderRadius(8)
                .height(38)
                .margin({ left: 10 })
                .onClick(() => {
                  this.viewArrivalPrediction(this.selectedRoute!.routeId);
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ top: 14 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .shadow({ radius: 4, offsetY: 2, color: 'rgba(0,0,0,0.08)' })

            // 站点列表
            Text('途经站点 (' + this.routeStations.length + '站)')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ top: 16, bottom: 8 })

            Column() {
              ForEach(this.routeStations, (station: RouteStation, index: number) => {
                Row() {
                  Column() {
                    if (index === 0) {
                      Circle()
                        .width(12)
                        .height(12)
                        .fill('#0078D4')
                    } else if (index === this.routeStations.length - 1) {
                      Circle()
                        .width(12)
                        .height(12)
                        .fill('#107C10')
                    } else {
                      Circle()
                        .width(8)
                        .height(8)
                        .fill('#CCCCCC')
                    }
                    if (index < this.routeStations.length - 1) {
                      Line()
                        .width(2)
                        .height(20)
                        .backgroundColor('#E0E0E0')
                        .margin({ top: 2, bottom: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Center)
                  .margin({ right: 12 })
                  .width(20)

                  Text(station.stationName)
                    .fontSize(15)
                    .fontColor(index === 0 ? '#0078D4' : (index === this.routeStations.length - 1 ? '#107C10' : '#333333'))
                    .fontWeight(index === 0 || index === this.routeStations.length - 1 ? FontWeight.Medium : FontWeight.Regular)
                }
                .width('100%')
                .padding({ left: 12, top: 4, bottom: 4 })
              }, (station: RouteStation) => station.stationId)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(12)
            .shadow({ radius: 4, offsetY: 2, color: 'rgba(0,0,0,0.08)' })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      } else {
        // 搜索列表
        Scroll() {
          Column() {
            if (!this.hasSearched) {
              Column() {
                Text('🔍')
                  .fontSize(48)
                Text('输入线路名称或编号进行查询')
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ top: 16 })
                Text('例如：1路、1号线、B001')
                  .fontSize(13)
                  .fontColor('#BBBBBB')
                  .margin({ top: 8 })
              }
              .width('100%')
              .margin({ top: 80 })
              .alignItems(HorizontalAlign.Center)
            } else if (this.searchResults.length === 0) {
              Column() {
                Text('😕')
                  .fontSize(48)
                Text('未找到相关线路')
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ top: 16 })
              }
              .width('100%')
              .margin({ top: 80 })
              .alignItems(HorizontalAlign.Center)
            } else {
              Text('找到 ' + this.searchResults.length + ' 条线路')
                .fontSize(13)
                .fontColor('#888888')
                .width('100%')
                .padding({ left: 4, bottom: 8 })

              ForEach(this.searchResults, (route: RouteInfo, index: number) => {
                Column() {
                  Row() {
                    Text(this.getRouteTypeIcon(route.routeType))
                      .fontSize(24)
                    Column() {
                      Text(route.routeName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                      Text(route.startStation + ' → ' + route.endStation)
                        .fontSize(13)
                        .fontColor('#888888')
                        .margin({ top: 3 })
                    }
                    .margin({ left: 10 })
                    .alignItems(HorizontalAlign.Start)
                    Blank()
                    Text('>')
                      .fontSize(16)
                      .fontColor('#CCCCCC')
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
                .onClick(() => {
                  this.selectRoute(route);
                })
              }, (route: RouteInfo) => route.routeId)
            }
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
