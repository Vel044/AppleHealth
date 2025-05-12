
import { CommonConstants } from '../common/constants/CommonConstants';

@CustomDialog
export default struct InputDialog {
  @Consume stepGoal: string;
  controller?: CustomDialogController;
  cancel?: () => void;
  confirm?: () => void;

  build() {
    Column() {
      Text($r('app.string.steps'))
        .width(CommonConstants.FULL_WIDTH)
        .height($r('app.float.input_text_height'))
        .fontSize($r('app.float.input_text_font_size'))
        .fontColor($r('app.color.step_text_font'))
        .fontWeight(CommonConstants.BIG_FONT_WEIGHT)
        .textAlign(TextAlign.Start)
        .margin({
          top: $r('app.float.input_margin_top'),
          bottom: $r('app.float.input_margin_bottom'),
          left: $r('app.float.input_margin_left')
        })

      TextInput({ placeholder: this.stepGoal === '' ? $r('app.string.placeholder') : this.stepGoal })
        .width(CommonConstants.FULL_WIDTH)
        .type(InputType.Number)
        .fontSize($r('app.float.input_font_size'))
        .alignSelf(ItemAlign.Start)
        .backgroundColor(Color.White)
        .margin({
          top: $r('app.float.text_margin_top'),
          bottom: $r('app.float.text_margin_bottom')
        })
        .onChange((value: string) => {
          this.stepGoal = value;
        })

      Divider()
        .width(CommonConstants.DIVIDER_WIDTH)
        .height($r('app.float.divider_height'))
        .vertical(false)
        .color($r('app.color.divider'))
        .strokeWidth(CommonConstants.DIVIDER_STROKE_WIDTH)

      Row() {
        Text($r('app.string.cancel'))
          .width($r('app.float.text_width'))
          .height($r('app.float.text_height'))
          .fontColor($r('app.color.input_text_font'))
          .fontWeight(CommonConstants.BIG_FONT_WEIGHT)
          .fontSize($r('app.float.text_font_size'))
          .textAlign(TextAlign.Center)
          .margin({ right: $r('app.float.text_margin_right') })
          .onClick(() => {
            if(this.controller) {
              this.controller.close();
            }
            if(this.cancel) {
              this.cancel();
            }
          })

        Divider()
          .height($r('app.float.divider_height'))
          .vertical(true)
          .color($r('app.color.divider'))
          .strokeWidth(CommonConstants.DIVIDER_STROKE_WIDTH)

        Text($r('app.string.confirm'))
          .width($r('app.float.text_width'))
          .height($r('app.float.text_height'))
          .fontColor($r('app.color.input_text_font'))
          .fontWeight(CommonConstants.BIG_FONT_WEIGHT)
          .fontSize($r('app.float.text_font_size'))
          .textAlign(TextAlign.Center)
          .margin({ left: $r('app.float.text_margin_left') })
          .fontColor($r('app.color.input_text_font'))
          .onClick(() => {
            if(this.controller) {
              this.controller.close();
            }
            if(this.confirm) {
              this.confirm();
            }
          })
      }
      .margin({
        top: $r('app.float.row_margin_top'),
        bottom: $r('app.float.row_margin_bottom'),
        left: $r('app.float.row_margin_left')
      })
    }
    .width(CommonConstants.DIALOG_WIDTH)
    .borderRadius($r('app.float.dialog_border_radius'))
    .backgroundColor(Color.White)
  }
}