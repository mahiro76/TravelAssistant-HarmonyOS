import { relationalStore } from '@kit.ArkData';
import { contextConstant } from '@kit.AbilityKit';
import { Constants } from '../common/Constants';
import { FavoriteRoute } from '../model/FavoriteData';
import { ReminderInfo } from '../model/FavoriteData';
import { RouteInfo, RouteType } from '../model/RouteData';
import { StationInfo } from '../model/StationData';

export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    if (DatabaseHelper.instance == null) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  async init(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: Constants.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.rdbStore = await relationalStore.getRdbStore(context, config);
    await this.createTables();
  }

  private async createTables(): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }

    const createFavoritesTable: string =
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_FAVORITES} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id TEXT NOT NULL,
        route_name TEXT NOT NULL,
        route_type TEXT NOT NULL,
        start_station TEXT NOT NULL,
        end_station TEXT NOT NULL,
        create_time INTEGER NOT NULL
      )`;

    const createRemindersTable: string =
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_REMINDERS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id TEXT NOT NULL,
        route_name TEXT NOT NULL,
        station_id TEXT NOT NULL,
        station_name TEXT NOT NULL,
        direction TEXT NOT NULL,
        remind_before_stops INTEGER DEFAULT 1,
        is_enabled INTEGER DEFAULT 1,
        create_time INTEGER NOT NULL
      )`;

    const createCacheRoutesTable: string =
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_CACHE_ROUTES} (
        route_id TEXT PRIMARY KEY,
        route_name TEXT NOT NULL,
        route_type TEXT NOT NULL,
        start_station TEXT NOT NULL,
        end_station TEXT NOT NULL,
        first_bus_time TEXT,
        last_bus_time TEXT,
        price REAL DEFAULT 0,
        company TEXT,
        cache_time INTEGER NOT NULL
      )`;

    const createCacheStationsTable: string =
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_CACHE_STATIONS} (
        station_id TEXT PRIMARY KEY,
        station_name TEXT NOT NULL,
        longitude REAL DEFAULT 0,
        latitude REAL DEFAULT 0,
        routes TEXT,
        district TEXT,
        cache_time INTEGER NOT NULL
      )`;

    await this.rdbStore.executeSql(createFavoritesTable);
    await this.rdbStore.executeSql(createRemindersTable);
    await this.rdbStore.executeSql(createCacheRoutesTable);
    await this.rdbStore.executeSql(createCacheStationsTable);
  }

  // ==================== 收藏路线操作 ====================

  async addFavorite(favorite: FavoriteRoute): Promise<number> {
    if (this.rdbStore == null) {
      return -1;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'route_id': favorite.routeId,
      'route_name': favorite.routeName,
      'route_type': favorite.routeType,
      'start_station': favorite.startStation,
      'end_station': favorite.endStation,
      'create_time': Date.now()
    };
    return await this.rdbStore.insert(Constants.TABLE_FAVORITES, valueBucket);
  }

  async removeFavorite(id: number): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FAVORITES);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }

  async removeFavoriteByRouteId(routeId: string): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FAVORITES);
    predicates.equalTo('route_id', routeId);
    await this.rdbStore.delete(predicates);
  }

  async getAllFavorites(): Promise<FavoriteRoute[]> {
    if (this.rdbStore == null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FAVORITES);
    predicates.orderByDesc('create_time');
    const resultSet = await this.rdbStore.query(predicates, ['id', 'route_id', 'route_name', 'route_type', 'start_station', 'end_station', 'create_time']);
    const favorites: FavoriteRoute[] = [];
    while (resultSet.goToNextRow()) {
      favorites.push(new FavoriteRoute(
        resultSet.getLong(0),
        resultSet.getString(1),
        resultSet.getString(2),
        resultSet.getString(3) as RouteType,
        resultSet.getString(4),
        resultSet.getString(5),
        resultSet.getLong(6)
      ));
    }
    resultSet.close();
    return favorites;
  }

  async isFavorite(routeId: string): Promise<boolean> {
    if (this.rdbStore == null) {
      return false;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FAVORITES);
    predicates.equalTo('route_id', routeId);
    const resultSet = await this.rdbStore.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    return count > 0;
  }

  // ==================== 到站提醒操作 ====================

  async addReminder(reminder: ReminderInfo): Promise<number> {
    if (this.rdbStore == null) {
      return -1;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'route_id': reminder.routeId,
      'route_name': reminder.routeName,
      'station_id': reminder.stationId,
      'station_name': reminder.stationName,
      'direction': reminder.direction,
      'remind_before_stops': reminder.remindBeforeStops,
      'is_enabled': reminder.isEnabled ? 1 : 0,
      'create_time': Date.now()
    };
    return await this.rdbStore.insert(Constants.TABLE_REMINDERS, valueBucket);
  }

  async removeReminder(id: number): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_REMINDERS);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }

  async updateReminderStatus(id: number, isEnabled: boolean): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_REMINDERS);
    predicates.equalTo('id', id);
    const valueBucket: relationalStore.ValuesBucket = {
      'is_enabled': isEnabled ? 1 : 0
    };
    await this.rdbStore.update(valueBucket, predicates);
  }

  async getAllReminders(): Promise<ReminderInfo[]> {
    if (this.rdbStore == null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_REMINDERS);
    predicates.orderByDesc('create_time');
    const resultSet = await this.rdbStore.query(predicates,
      ['id', 'route_id', 'route_name', 'station_id', 'station_name', 'direction', 'remind_before_stops', 'is_enabled', 'create_time']);
    const reminders: ReminderInfo[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(new ReminderInfo(
        resultSet.getLong(0),
        resultSet.getString(1),
        resultSet.getString(2),
        resultSet.getString(3),
        resultSet.getString(4),
        resultSet.getString(5),
        resultSet.getLong(6),
        resultSet.getLong(7) === 1,
        resultSet.getLong(8)
      ));
    }
    resultSet.close();
    return reminders;
  }

  // ==================== 离线缓存操作 ====================

  async cacheRoute(route: RouteInfo): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'route_id': route.routeId,
      'route_name': route.routeName,
      'route_type': route.routeType,
      'start_station': route.startStation,
      'end_station': route.endStation,
      'first_bus_time': route.firstBusTime,
      'last_bus_time': route.lastBusTime,
      'price': route.price,
      'company': route.company,
      'cache_time': Date.now()
    };
    const sqlInsertOrReplace =
      `INSERT OR REPLACE INTO ${Constants.TABLE_CACHE_ROUTES} 
      (route_id, route_name, route_type, start_station, end_station, first_bus_time, last_bus_time, price, company, cache_time) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
    await this.rdbStore.executeSql(sqlInsertOrReplace,
      [route.routeId, route.routeName, route.routeType, route.startStation, route.endStation,
      route.firstBusTime, route.lastBusTime, route.price, route.company, Date.now()]);
  }

  async getCachedRoute(routeId: string): Promise<RouteInfo | null> {
    if (this.rdbStore == null) {
      return null;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_CACHE_ROUTES);
    predicates.equalTo('route_id', routeId);
    const resultSet = await this.rdbStore.query(predicates,
      ['route_id', 'route_name', 'route_type', 'start_station', 'end_station', 'first_bus_time', 'last_bus_time', 'price', 'company']);
    if (resultSet.goToFirstRow()) {
      const route = new RouteInfo(
        resultSet.getString(0),
        resultSet.getString(1),
        resultSet.getString(2) as RouteType,
        resultSet.getString(3),
        resultSet.getString(4),
        resultSet.getString(5),
        resultSet.getString(6),
        resultSet.getDouble(7),
        resultSet.getString(8)
      );
      resultSet.close();
      return route;
    }
    resultSet.close();
    return null;
  }

  async getCachedRoutes(): Promise<RouteInfo[]> {
    if (this.rdbStore == null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_CACHE_ROUTES);
    const resultSet = await this.rdbStore.query(predicates,
      ['route_id', 'route_name', 'route_type', 'start_station', 'end_station', 'first_bus_time', 'last_bus_time', 'price', 'company']);
    const routes: RouteInfo[] = [];
    while (resultSet.goToNextRow()) {
      routes.push(new RouteInfo(
        resultSet.getString(0),
        resultSet.getString(1),
        resultSet.getString(2) as RouteType,
        resultSet.getString(3),
        resultSet.getString(4),
        resultSet.getString(5),
        resultSet.getString(6),
        resultSet.getDouble(7),
        resultSet.getString(8)
      ));
    }
    resultSet.close();
    return routes;
  }

  async cacheStation(station: StationInfo): Promise<void> {
    if (this.rdbStore == null) {
      return;
    }
    const sqlInsertOrReplace =
      `INSERT OR REPLACE INTO ${Constants.TABLE_CACHE_STATIONS} 
      (station_id, station_name, longitude, latitude, routes, district, cache_time) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`;
    await this.rdbStore.executeSql(sqlInsertOrReplace,
      [station.stationId, station.stationName, station.longitude, station.latitude,
      station.routes.join(','), station.district, Date.now()]);
  }

  async getCachedStation(stationId: string): Promise<StationInfo | null> {
    if (this.rdbStore == null) {
      return null;
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_CACHE_STATIONS);
    predicates.equalTo('station_id', stationId);
    const resultSet = await this.rdbStore.query(predicates,
      ['station_id', 'station_name', 'longitude', 'latitude', 'routes', 'district']);
    if (resultSet.goToFirstRow()) {
      const station = new StationInfo(
        resultSet.getString(0),
        resultSet.getString(1),
        resultSet.getDouble(2),
        resultSet.getDouble(3),
        resultSet.getString(4).split(','),
        resultSet.getString(5)
      );
      resultSet.close();
      return station;
    }
    resultSet.close();
    return null;
  }
}
