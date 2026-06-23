import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

export default class FavoritesAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onWindowStageCreate');

    windowStage.loadContent('pages/Favorites', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading FavoritesAbility content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', 'FavoritesAbility onBackground');
  }
}
