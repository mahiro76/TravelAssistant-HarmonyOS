import { preferences } from '@kit.ArkData';
import { Constants } from '../common/Constants';

export class PreferencesHelper {
  private static instance: PreferencesHelper;
  private preferences: preferences.Preferences | null = null;

  private constructor() {
  }

  static getInstance(): PreferencesHelper {
    if (PreferencesHelper.instance == null) {
      PreferencesHelper.instance = new PreferencesHelper();
    }
    return PreferencesHelper.instance;
  }

  async init(context: Context): Promise<void> {
    this.preferences = await preferences.getPreferences(context, 'TravelAssistantPrefs');
  }

  async getString(key: string, defaultValue: string): Promise<string> {
    if (this.preferences == null) {
      return defaultValue;
    }
    return await this.preferences.get(key, defaultValue) as string;
  }

  async setString(key: string, value: string): Promise<void> {
    if (this.preferences == null) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    if (this.preferences == null) {
      return defaultValue;
    }
    return await this.preferences.get(key, defaultValue) as boolean;
  }

  async setBoolean(key: string, value: boolean): Promise<void> {
    if (this.preferences == null) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async getNumber(key: string, defaultValue: number): Promise<number> {
    if (this.preferences == null) {
      return defaultValue;
    }
    return await this.preferences.get(key, defaultValue) as number;
  }

  async setNumber(key: string, value: number): Promise<void> {
    if (this.preferences == null) {
      return;
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  async isDistributeSyncEnabled(): Promise<boolean> {
    return await this.getBoolean(Constants.PREF_KEY_DISTRIBUTE_SYNC, false);
  }

  async setDistributeSyncEnabled(enabled: boolean): Promise<void> {
    await this.setBoolean(Constants.PREF_KEY_DISTRIBUTE_SYNC, enabled);
  }

  async isOfflineModeEnabled(): Promise<boolean> {
    return await this.getBoolean(Constants.PREF_KEY_OFFLINE_MODE, false);
  }

  async setOfflineModeEnabled(enabled: boolean): Promise<void> {
    await this.setBoolean(Constants.PREF_KEY_OFFLINE_MODE, enabled);
  }

  async isNotificationEnabled(): Promise<boolean> {
    return await this.getBoolean(Constants.PREF_KEY_NOTIFICATION_ENABLED, true);
  }

  async setNotificationEnabled(enabled: boolean): Promise<void> {
    await this.setBoolean(Constants.PREF_KEY_NOTIFICATION_ENABLED, enabled);
  }

  async getThemeMode(): Promise<string> {
    return await this.getString(Constants.PREF_KEY_THEME_MODE, 'light');
  }

  async setThemeMode(mode: string): Promise<void> {
    await this.setString(Constants.PREF_KEY_THEME_MODE, mode);
  }
}
