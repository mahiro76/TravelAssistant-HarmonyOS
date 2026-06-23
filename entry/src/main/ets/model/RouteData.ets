export enum RouteType {
  BUS = '公交',
  SUBWAY = '地铁'
}

export enum DirectionType {
  UP = '上行',
  DOWN = '下行'
}

export class RouteInfo {
  routeId: string;
  routeName: string;
  routeType: RouteType;
  startStation: string;
  endStation: string;
  firstBusTime: string;
  lastBusTime: string;
  price: number;
  company: string;

  constructor(
    routeId: string,
    routeName: string,
    routeType: RouteType,
    startStation: string,
    endStation: string,
    firstBusTime: string,
    lastBusTime: string,
    price: number,
    company: string
  ) {
    this.routeId = routeId;
    this.routeName = routeName;
    this.routeType = routeType;
    this.startStation = startStation;
    this.endStation = endStation;
    this.firstBusTime = firstBusTime;
    this.lastBusTime = lastBusTime;
    this.price = price;
    this.company = company;
  }
}
