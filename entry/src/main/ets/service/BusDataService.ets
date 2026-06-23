import { RouteInfo, RouteType } from '../model/RouteData';
import { StationInfo, StationArrival, RouteStation } from '../model/StationData';
import { DatabaseHelper } from '../database/DatabaseHelper';

export class BusDataService {
  private static instance: BusDataService;
  private dbHelper: DatabaseHelper;

  // 模拟公交数据
  private mockRoutes: RouteInfo[] = [
    new RouteInfo('B001', '1路', RouteType.BUS, '火车站', '机场', '06:00', '22:00', 2, '市公交集团'),
    new RouteInfo('B002', '2路', RouteType.BUS, '大学城', '市中心', '06:30', '21:30', 2, '市公交集团'),
    new RouteInfo('B003', '3路', RouteType.BUS, '高铁站', '风景区', '06:00', '23:00', 3, '市公交集团'),
    new RouteInfo('B004', '5路', RouteType.BUS, '人民医院', '科技园', '06:15', '21:45', 2, '市公交集团'),
    new RouteInfo('B005', '8路', RouteType.BUS, '老城区', '新城区', '05:50', '22:30', 2, '市公交集团'),
    new RouteInfo('B006', '12路', RouteType.BUS, '火车站', '大学城', '06:10', '22:10', 2, '市公交集团'),
    new RouteInfo('B007', '18路', RouteType.BUS, '体育馆', '市中心', '06:20', '21:50', 2, '市公交集团'),
    new RouteInfo('B008', '22路', RouteType.BUS, '机场', '高铁站', '06:00', '23:30', 4, '市公交集团'),
    new RouteInfo('M001', '1号线', RouteType.SUBWAY, '东山', '西山', '06:00', '23:00', 5, '市轨道交通集团'),
    new RouteInfo('M002', '2号线', RouteType.SUBWAY, '北站', '南站', '06:15', '22:45', 5, '市轨道交通集团'),
    new RouteInfo('M003', '3号线', RouteType.SUBWAY, '大学城', '高新区', '06:30', '22:30', 4, '市轨道交通集团'),
    new RouteInfo('M004', '4号线', RouteType.SUBWAY, '火车站', '会展中心', '06:00', '23:15', 5, '市轨道交通集团'),
    new RouteInfo('M005', '5号线', RouteType.SUBWAY, '机场', '市中心', '06:10', '22:50', 6, '市轨道交通集团')
  ];

  // 模拟站点数据
  private mockStations: StationInfo[] = [
    new StationInfo('S001', '火车站', 116.397, 39.908, ['B001', 'B006', 'M004'], '市中心'),
    new StationInfo('S002', '机场', 116.585, 40.080, ['B001', 'B008', 'M005'], '郊区'),
    new StationInfo('S003', '大学城', 116.358, 39.992, ['B002', 'B006', 'M003'], '大学园区'),
    new StationInfo('S004', '市中心', 116.407, 39.904, ['B002', 'B007', 'M005'], '市中心'),
    new StationInfo('S005', '高铁站', 116.428, 39.919, ['B003', 'B008'], '市中心'),
    new StationInfo('S006', '风景区', 116.221, 39.896, ['B003'], '郊区'),
    new StationInfo('S007', '人民医院', 116.376, 39.908, ['B004'], '市中心'),
    new StationInfo('S008', '科技园', 116.480, 39.996, ['B004'], '高新区'),
    new StationInfo('S009', '老城区', 116.390, 39.905, ['B005'], '老城区'),
    new StationInfo('S010', '新城区', 116.470, 39.915, ['B005'], '新城区'),
    new StationInfo('S011', '体育馆', 116.356, 39.941, ['B007'], '文体中心'),
    new StationInfo('S012', '东山', 116.328, 39.900, ['M001'], '东山区'),
    new StationInfo('S013', '西山', 116.285, 39.871, ['M001'], '西山区'),
    new StationInfo('S014', '北站', 116.395, 39.940, ['M002'], '北城区'),
    new StationInfo('S015', '南站', 116.420, 39.860, ['M002'], '南城区'),
    new StationInfo('S016', '高新区', 116.459, 39.981, ['M003'], '高新区'),
    new StationInfo('S017', '会展中心', 116.435, 39.911, ['M004'], '市中心'),
    new StationInfo('S018', '东山口', 116.340, 39.908, ['M001', 'M002'], '东山区'),
    new StationInfo('S019', '西山口', 116.300, 39.885, ['M001'], '西山区'),
    new StationInfo('S020', '南湖', 116.410, 39.880, ['M002'], '南城区')
  ];

  // 模拟站点路线序列
  private routeStations: Map<string, RouteStation[]> = new Map();

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
    this.initRouteStations();
  }

  static getInstance(): BusDataService {
    if (BusDataService.instance == null) {
      BusDataService.instance = new BusDataService();
    }
    return BusDataService.instance;
  }

  private initRouteStations(): void {
    this.routeStations.set('B001', [
      new RouteStation('S001', '火车站', 1),
      new RouteStation('S003', '大学城', 2),
      new RouteStation('S002', '机场', 3)
    ]);
    this.routeStations.set('B002', [
      new RouteStation('S003', '大学城', 1),
      new RouteStation('S004', '市中心', 2)
    ]);
    this.routeStations.set('B003', [
      new RouteStation('S005', '高铁站', 1),
      new RouteStation('S006', '风景区', 2)
    ]);
    this.routeStations.set('B004', [
      new RouteStation('S007', '人民医院', 1),
      new RouteStation('S008', '科技园', 2)
    ]);
    this.routeStations.set('B005', [
      new RouteStation('S009', '老城区', 1),
      new RouteStation('S010', '新城区', 2)
    ]);
    this.routeStations.set('B006', [
      new RouteStation('S001', '火车站', 1),
      new RouteStation('S003', '大学城', 2)
    ]);
    this.routeStations.set('B007', [
      new RouteStation('S011', '体育馆', 1),
      new RouteStation('S004', '市中心', 2)
    ]);
    this.routeStations.set('B008', [
      new RouteStation('S002', '机场', 1),
      new RouteStation('S005', '高铁站', 2)
    ]);
    this.routeStations.set('M001', [
      new RouteStation('S012', '东山', 1),
      new RouteStation('S018', '东山口', 2),
      new RouteStation('S019', '西山口', 3),
      new RouteStation('S013', '西山', 4)
    ]);
    this.routeStations.set('M002', [
      new RouteStation('S014', '北站', 1),
      new RouteStation('S018', '东山口', 2),
      new RouteStation('S020', '南湖', 3),
      new RouteStation('S015', '南站', 4)
    ]);
    this.routeStations.set('M003', [
      new RouteStation('S003', '大学城', 1),
      new RouteStation('S016', '高新区', 2)
    ]);
    this.routeStations.set('M004', [
      new RouteStation('S001', '火车站', 1),
      new RouteStation('S017', '会展中心', 2)
    ]);
    this.routeStations.set('M005', [
      new RouteStation('S002', '机场', 1),
      new RouteStation('S004', '市中心', 2)
    ]);
  }

  // 搜索路线
  async searchRoutes(keyword: string): Promise<RouteInfo[]> {
    const result: RouteInfo[] = [];
    const lowerKeyword = keyword.toLowerCase();
    for (const route of this.mockRoutes) {
      if (route.routeName.toLowerCase().includes(lowerKeyword) ||
        route.routeId.toLowerCase().includes(lowerKeyword) ||
        route.startStation.includes(keyword) ||
        route.endStation.includes(keyword)) {
        result.push(route);
      }
    }
    // 缓存查询结果
    for (const route of result) {
      await this.dbHelper.cacheRoute(route);
    }
    return result;
  }

  async getAllRoutes(): Promise<RouteInfo[]> {
    return this.mockRoutes;
  }

  async getRouteById(routeId: string): Promise<RouteInfo | null> {
    const route = this.mockRoutes.find(r => r.routeId === routeId);
    if (route) {
      return route;
    }
    // 尝试从缓存获取
    return await this.dbHelper.getCachedRoute(routeId);
  }

  // 搜索站点
  async searchStations(keyword: string): Promise<StationInfo[]> {
    const result: StationInfo[] = [];
    for (const station of this.mockStations) {
      if (station.stationName.includes(keyword) ||
        station.stationId.toLowerCase().includes(keyword.toLowerCase())) {
        result.push(station);
      }
    }
    return result;
  }

  async getStationById(stationId: string): Promise<StationInfo | null> {
    return this.mockStations.find(s => s.stationId === stationId) || null;
  }

  // 获取路线站点列表
  async getRouteStations(routeId: string): Promise<RouteStation[]> {
    return this.routeStations.get(routeId) || [];
  }

  // 模拟实时到站预测
  async getArrivalPredictions(routeId: string, stationId: string): Promise<StationArrival[]> {
    const predictions: StationArrival[] = [];
    const route = this.mockRoutes.find(r => r.routeId === routeId);
    const station = this.mockStations.find(s => s.stationId === stationId);
    if (route && station) {
      const stations = this.routeStations.get(routeId) || [];
      const stationIndex = stations.findIndex(s => s.stationId === stationId);
      if (stationIndex >= 0) {
        // 模拟两个方向的到站预测
        predictions.push(new StationArrival(
          routeId, route.routeName, stationId, station.stationName,
          '上行', Math.floor(Math.random() * 15) + 1,
          Math.floor(Math.random() * 500) + 100, '京A·' + (Math.floor(Math.random() * 90000) + 10000)
        ));
        predictions.push(new StationArrival(
          routeId, route.routeName, stationId, station.stationName,
          '上行', Math.floor(Math.random() * 20) + 3,
          Math.floor(Math.random() * 500) + 200, '京A·' + (Math.floor(Math.random() * 90000) + 10000)
        ));
        predictions.push(new StationArrival(
          routeId, route.routeName, stationId, station.stationName,
          '下行', Math.floor(Math.random() * 10) + 2,
          Math.floor(Math.random() * 300) + 50, '京A·' + (Math.floor(Math.random() * 90000) + 10000)
        ));
        // 按到站时间排序
        predictions.sort((a, b) => a.arrivalTimeInMinutes - b.arrivalTimeInMinutes);
      }
    }
    return predictions;
  }

  // 获取所有模拟路线用于缓存
  async cacheAllRoutes(): Promise<void> {
    for (const route of this.mockRoutes) {
      await this.dbHelper.cacheRoute(route);
    }
  }
}
