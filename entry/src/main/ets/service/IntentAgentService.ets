import { wantAgent, common, Want } from '@kit.AbilityKit';
import { Constants } from '../common/Constants';

export class IntentAgentService {
  private static instance: IntentAgentService;

  private constructor() {
  }

  static getInstance(): IntentAgentService {
    if (IntentAgentService.instance == null) {
      IntentAgentService.instance = new IntentAgentService();
    }
    return IntentAgentService.instance;
  }

  async createRouteShortcut(
    context: common.UIAbilityContext,
    routeId: string,
    routeName: string
  ): Promise<void> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: Constants.BUNDLE_NAME,
            abilityName: 'EntryAbility',
            parameters: {
              'action': Constants.ACTION_VIEW_ROUTE,
              'routeId': routeId,
              'routeName': routeName
            } as Record<string, Object>
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 100
      };
      const agent = await wantAgent.getWantAgent(wantAgentInfo);

      const want: Want = {
        bundleName: Constants.BUNDLE_NAME,
        abilityName: 'EntryAbility',
        parameters: {
          'action': Constants.ACTION_VIEW_ROUTE,
          'routeId': routeId,
          'routeName': routeName
        } as Record<string, Object>
      };

      // 使用 WantAgent 触发快捷方式
      await wantAgent.trigger(agent, {
        code: 0
      });
      console.info('创建快捷方式成功：' + routeName);
    } catch (err) {
      console.error('创建快捷方式失败: ' + JSON.stringify(err));
    }
  }

  async getRouteShortcutAgent(
    routeId: string,
    routeName: string
  ): Promise<object | null> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: Constants.BUNDLE_NAME,
            abilityName: 'EntryAbility',
            parameters: {
              'action': Constants.ACTION_VIEW_ROUTE,
              'routeId': routeId,
              'routeName': routeName
            } as Record<string, Object>
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 100
      };
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (err) {
      console.error('获取快捷方式Agent失败: ' + JSON.stringify(err));
      return null;
    }
  }

  async triggerNotificationClick(context: common.UIAbilityContext, routeId: string): Promise<void> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: Constants.BUNDLE_NAME,
            abilityName: 'EntryAbility',
            parameters: {
              'action': Constants.ACTION_VIEW_ROUTE,
              'routeId': routeId
            } as Record<string, Object>
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 101
      };
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      await wantAgent.trigger(agent, {
        code: 0
      });
    } catch (err) {
      console.error('触发WantAgent失败: ' + JSON.stringify(err));
    }
  }
}
