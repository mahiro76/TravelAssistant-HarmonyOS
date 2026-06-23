export class StationInfo {
  stationId: string;
  stationName: string;
  longitude: number;
  latitude: number;
  routes: string[];
  district: string;

  constructor(
    stationId: string,
    stationName: string,
    longitude: number,
    latitude: number,
    routes: string[],
    district: string
  ) {
    this.stationId = stationId;
    this.stationName = stationName;
    this.longitude = longitude;
    this.latitude = latitude;
    this.routes = routes;
    this.district = district;
  }
}

export class StationArrival {
  routeId: string;
  routeName: string;
  stationId: string;
  stationName: string;
  direction: string;
  arrivalTimeInMinutes: number;
  distance: number;
  plateNumber: string;

  constructor(
    routeId: string,
    routeName: string,
    stationId: string,
    stationName: string,
    direction: string,
    arrivalTimeInMinutes: number,
    distance: number,
    plateNumber: string
  ) {
    this.routeId = routeId;
    this.routeName = routeName;
    this.stationId = stationId;
    this.stationName = stationName;
    this.direction = direction;
    this.arrivalTimeInMinutes = arrivalTimeInMinutes;
    this.distance = distance;
    this.plateNumber = plateNumber;
  }
}

export class RouteStation {
  stationId: string;
  stationName: string;
  sequence: number;

  constructor(stationId: string, stationName: string, sequence: number) {
    this.stationId = stationId;
    this.stationName = stationName;
    this.sequence = sequence;
  }
}
