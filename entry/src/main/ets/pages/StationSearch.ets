import { router } from '@kit.ArkUI';
import { StationInfo } from '../model/StationData';
import { BusDataService } from '../service/BusDataService';

@Entry
@Component
struct StationSearch {
  @State searchKeyword: string = '';
  @State searchResults: StationInfo[] = [];
  @State hasSearched: boolean = false;
  @State selectedStation: StationInfo | null = null;

  private busService: BusDataService = BusDataService.getInstance();
  private searchTimerId: number = -1;

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
    this.searchResults = await this.busService.searchStations(this.searchKeyword.trim());
    this.hasSearched = true;
  }

  selectStation(station: StationInfo): void {
    this.selectedStation = station;
  }

  viewRoute(routeId: string): void {
    router.pushUrl({
      url: 'pages/ArrivalPrediction',
      params: { routeId: routeId, stationId: this.selectedStation?.stationId }
    });
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
        Text('站点查询')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .padding(16)

      // 搜索输入框
      Row() {
        Search({ value: this.searchKeyword, placeholder: '输入站点名称（如：火车站）' })
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

      if (this.selectedStation != null) {
        Scroll() {
          Column() {
            // 站点信息卡片
            Column() {
              Row() {
                Text('📍')
                  .fontSize(28)
                Text(this.selectedStation.stationName)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 10 })
              }
              .width('100%')

              Row() {
                Text('所在区域: ' + this.selectedStation.district)
                  .fontSize(13)
                  .fontColor('#888888')
                Blank()
                Text('站点编号: ' + this.selectedStation.stationId)
                  .fontSize(12)
                  .fontColor('#AAAAAA')
              }
              .width('100%')
              .margin({ top: 10 })

              Text('途经线路 (' + this.selectedStation.routes.length + '条)')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ top: 14 })

              ForEach(this.selectedStation.routes, (routeId: string, index: number) => {
                Row() {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill(routeId.startsWith('M') ? '#107C10' : '#0078D4')
                  Text(routeId)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .margin({ left: 10 })
                  Text('查看线路')
                    .fontSize(12)
                    .fontColor('#0078D4')
                  Blank()
                  Text('>')
                    .fontSize(14)
                    .fontColor('#CCCCCC')
                }
                .width('100%')
                .padding({ top: 10, bottom: 10, left: 4 })
                .borderRadius(6)
                .onClick(() => {
                  this.viewRoute(routeId);
                })
              }, (routeId: string) => routeId)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .shadow({ radius: 4, offsetY: 2, color: 'rgba(0,0,0,0.08)' })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      } else {
        Scroll() {
          Column() {
            if (!this.hasSearched) {
              Column() {
                Text('📍')
                  .fontSize(48)
                Text('输入站点名称查询途经线路')
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ top: 16 })
                Text('例如：火车站、大学城、机场')
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
                Text('未找到相关站点')
                  .fontSize(15)
                  .fontColor('#999999')
                  .margin({ top: 16 })
              }
              .width('100%')
              .margin({ top: 80 })
              .alignItems(HorizontalAlign.Center)
            } else {
              Text('找到 ' + this.searchResults.length + ' 个站点')
                .fontSize(13)
                .fontColor('#888888')
                .width('100%')
                .padding({ left: 4, bottom: 8 })

              ForEach(this.searchResults, (station: StationInfo, index: number) => {
                Column() {
                  Row() {
                    Text('📍')
                      .fontSize(20)
                    Column() {
                      Text(station.stationName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                      Text(station.district + ' · ' + station.routes.length + '条线路')
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
                  this.selectStation(station);
                })
              }, (station: StationInfo) => station.stationId)
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
