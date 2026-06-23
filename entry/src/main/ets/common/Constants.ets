export class Constants {
  static readonly APP_NAME: string = '便民出行助手';
  static readonly BUNDLE_NAME: string = 'top.mahiro76.travelassistant';

  // 数据库相关
  static readonly DATABASE_NAME: string = 'TravelAssistant.db';
  static readonly DATABASE_VERSION: number = 1;

  // 表名
  static readonly TABLE_FAVORITES: string = 'favorites';
  static readonly TABLE_REMINDERS: string = 'reminders';
  static readonly TABLE_CACHE_ROUTES: string = 'cache_routes';
  static readonly TABLE_CACHE_STATIONS: string = 'cache_stations';

  // 首选项键
  static readonly PREF_KEY_DISTRIBUTE_SYNC: string = 'distribute_sync_enabled';
  static readonly PREF_KEY_OFFLINE_MODE: string = 'offline_mode_enabled';
  static readonly PREF_KEY_THEME_MODE: string = 'theme_mode';
  static readonly PREF_KEY_NOTIFICATION_ENABLED: string = 'notification_enabled';

  // 公共事件
  static readonly EVENT_REMINDER_ARRIVAL: string = 'top.mahiro76.travelassistant.REMINDER_ARRIVAL';
  static readonly EVENT_FAVORITE_SYNC: string = 'top.mahiro76.travelassistant.FAVORITE_SYNC';
  static readonly EVENT_DATA_UPDATE: string = 'top.mahiro76.travelassistant.DATA_UPDATE';

  // IntentAgent 动作
  static readonly ACTION_VIEW_ROUTE: string = 'top.mahiro76.travelassistant.VIEW_ROUTE';
  static readonly ACTION_VIEW_FAVORITES: string = 'top.mahiro76.travelassistant.VIEW_FAVORITES';
  static readonly ACTION_VIEW_REMINDER: string = 'top.mahiro76.travelassistant.VIEW_REMINDER';

  // 通知
  static readonly NOTIFICATION_REMINDER_ID: number = 1001;
  static readonly NOTIFICATION_CHANNEL_REMINDER: string = 'arrival_reminder';
  static readonly NOTIFICATION_CHANNEL_SYSTEM: string = 'system_notification';
}
