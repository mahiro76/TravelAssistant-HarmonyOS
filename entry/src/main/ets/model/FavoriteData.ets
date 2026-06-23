import { RouteInfo, RouteType } from './RouteData';

export class FavoriteRoute {
  id: number;
  routeId: string;
  routeName: string;
  routeType: RouteType;
  startStation: string;
  endStation: string;
  createTime: number;

  constructor(
    id: number,
    routeId: string,
    routeName: string,
    routeType: RouteType,
    startStation: string,
    endStation: string,
    createTime: number
  ) {
    this.id = id;
    this.routeId = routeId;
    this.routeName = routeName;
    this.routeType = routeType;
    this.startStation = startStation;
    this.endStation = endStation;
    this.createTime = createTime;
  }

  static fromRouteInfo(route: RouteInfo): FavoriteRoute {
    return new FavoriteRoute(
      0,
      route.routeId,
      route.routeName,
      route.routeType,
      route.startStation,
      route.endStation,
      Date.now()
    );
  }
}

export class ReminderInfo {
  id: number;
  routeId: string;
  routeName: string;
  stationId: string;
  stationName: string;
  direction: string;
  remindBeforeStops: number;
  isEnabled: boolean;
  createTime: number;

  constructor(
    id: number,
    routeId: string,
    routeName: string,
    stationId: string,
    stationName: string,
    direction: string,
    remindBeforeStops: number,
    isEnabled: boolean,
    createTime: number
  ) {
    this.id = id;
    this.routeId = routeId;
    this.routeName = routeName;
    this.stationId = stationId;
    this.stationName = stationName;
    this.direction = direction;
    this.remindBeforeStops = remindBeforeStops;
    this.isEnabled = isEnabled;
    this.createTime = createTime;
  }
}
