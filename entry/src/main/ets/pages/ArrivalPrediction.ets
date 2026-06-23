import { router } from '@kit.ArkUI';
import { StationArrival, RouteStation } from '../model/StationData';
import { RouteInfo } from '../model/RouteData';
import { BusDataService } from '../service/BusDataService';

@Entry
@Component
struct ArrivalPrediction {
  @State routeId: string = '';
  @State stationId: string = '';
  @State routeInfo: RouteInfo | null = null;
  @State stations: RouteStation[] = [];
  @State selectedStationIndex: number = -1;
  @State predictions: StationArrival[] = [];
  @State hasPredicted: boolean = false;
  @State isLoading: boolean = false;

  private busService: BusDataService = BusDataService.getInstance();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.routeId = params['routeId'] || '';
      this.stationId = params['stationId'] || '';
    }
    this.loadRouteInfo();
  }

  async loadRouteInfo(): Promise<void> {
    if (this.routeId) {
      this.routeInfo = await this.busService.getRouteById(this.routeId);
      this.stations = await this.busService.getRouteStations(this.routeId);
      if (this.stationId) {
        const idx = this.stations.findIndex(s => s.stationId === this.stationId);
        if (idx >= 0) {
          this.selectedStationIndex = idx;
          this.getPredictions();
        }
      }
    }
  }

  async getPredictions(): Promise<void> {
    if (!this.routeInfo || this.selectedStationIndex < 0) {
      return;
    }
    this.isLoading = true;
    this.hasPredicted = true;
    const station = this.stations[this.selectedStationIndex];
    this.predictions = await this.busService.getArrivalPredictions(this.routeInfo.routeId, station.stationId);
    this.isLoading = false;
  }

  getRouteIcon(): string {
    if (this.routeInfo) {
      return this.routeInfo.routeName.includes('号线') ? '🚇' : '🚍';
    }
    return '🚍';
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
        Text('实时到站预测')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // 路线信息
          if (this.routeInfo) {
            Column() {
              Row() {
                Text(this.getRouteIcon())
                  .fontSize(28)
                Text(this.routeInfo.routeName)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 8 })
                Blank()
                Text(this.routeInfo.startStation + '→' + this.routeInfo.endStation)
                  .fontSize(12)
                  .fontColor('#888888')
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .shadow({ radius: 4, offsetY: 2, color: 'rgba(0,0,0,0.08)' })
          }

          // 站点选择
          Text('选择站点查看实时到站信息')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ top: 16, bottom: 8 })

          Row() {
            if (this.stations.length > 0) {
              Scroll() {
                Row() {
                  ForEach(this.stations, (station: RouteStation, index: number) => {
                    Column() {
                      Text(station.stationName)
                        .fontSize(13)
                        .fontColor(this.selectedStationIndex === index ? '#FFFFFF' : '#333333')
                        .fontWeight(this.selectedStationIndex === index ? FontWeight.Medium : FontWeight.Regular)
                        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    }
                    .backgroundColor(this.selectedStationIndex === index ? '#0078D4' : '#F0F0F0')
                    .borderRadius(20)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedStationIndex = index;
                      this.getPredictions();
                    })
                  }, (station: RouteStation) => station.stationId)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
            }
          }
          .width('100%')
          .padding(2)

          // 到站预测结果
          if (this.hasPredicted) {
            if (this.isLoading) {
              Column() {
                LoadingProgress()
                  .width(32)
                  .height(32)
                Text('查询中...')
                  .fontSize(14)
                  .fontColor('#888888')
                  .margin({ top: 8 })
              }
              .width('100%')
              .margin({ top: 40 })
              .alignItems(HorizontalAlign.Center)
            } else if (this.predictions.length > 0) {
              Text('到站预测结果')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ top: 16, bottom: 8 })

              ForEach(this.predictions, (prediction: StationArrival, index: number) => {
                Column() {
                  Row() {
                    Column() {
                      Text(prediction.arrivalTimeInMinutes.toString())
                        .fontSize(28)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(prediction.arrivalTimeInMinutes <= 3 ? '#E81224' : '#0078D4')
                      Text('分钟')
                        .fontSize(12)
                        .fontColor('#888888')
                    }
                    .alignItems(HorizontalAlign.Center)
                    .width(60)

                    Column() {
                      Text(prediction.direction + '方向 · ' + prediction.plateNumber)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                      Row() {
                        Text('距离约' + prediction.distance + '米')
                          .fontSize(12)
                          .fontColor('#888888')
                        Blank()
                        Text(prediction.arrivalTimeInMinutes <= 3 ? '即将进站' : '正常行驶')
                          .fontSize(12)
                          .fontColor(prediction.arrivalTimeInMinutes <= 3 ? '#E81224' : '#107C10')
                      }
                      .width('100%')
                      .margin({ top: 4 })
                    }
                    .margin({ left: 12 })
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
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
              }, (prediction: StationArrival) => prediction.plateNumber)
            } else {
              Column() {
                Text('暂无到站预测数据')
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ top: 40 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
          } else {
            Column() {
              Text('⏱️')
                .fontSize(48)
              Text('选择站点后查看实时到站预测')
                .fontSize(15)
                .fontColor('#999999')
                .margin({ top: 16 })
            }
            .width('100%')
            .margin({ top: 80 })
            .alignItems(HorizontalAlign.Center)
          }
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
