package LoaderSources
{
  import BaseClasses.BaseIconLoader;
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.text.TextField;
  import src.ButtonTooltipEvent;

  public class LoaderHeroRaitingAccBar extends MovieClip
  {

    public var raitingBack:MovieClip;

    public var raiting_txt:TextField;

    public var eliteHero_mc:BaseIconLoader;
    А;

    private var tooltipText:String;

    private var ourPlayerTooltipTemplate:String;

    private var teamMateTooltipTemplate:String;

    public function LoaderHeroRaitingAccBar()
    {
      super();
      this.visible = false;
      addEventListener(MouseEvent.MOUSE_OVER, this.OnRaitingOver);
      addEventListener(MouseEvent.MOUSE_OUT, this.OnRaitingOut);
      this.ourPlayerTooltipTemplate = LoaderLocalization.OurPlayerRaitingAccTooltip;
      this.teamMateTooltipTemplate = LoaderLocalization.TeamMateRaitingAccTooltip;
      this.raiting_txt.mouseEnabled = false;
      if (LoaderLocalization.CompleteEventDispatcher != null)
      {
        LoaderLocalization.CompleteEventDispatcher.addEventListener(Event.COMPLETE, this.OnFillLocalization);
      }
    }

    private function OnFillLocalization(param1:Event):void
    {
      this.ourPlayerTooltipTemplate = LoaderLocalization.OurPlayerRaitingAccTooltip;
      this.teamMateTooltipTemplate = LoaderLocalization.TeamMateRaitingAccTooltip;
    }

    public function SetHeroRaiting(param1:Boolean, param2:int, param3:Number, param4:Number, param5:String, param6:String):void
    {
      this.visible = true;
      this.raiting_txt.text = param2.toString();
      this.eliteHero_mc.SetIcon(param5);
      this.tooltipText = param6 + (param1 ? this.ourPlayerTooltipTemplate : this.teamMateTooltipTemplate);
      this.tooltipText = this.tooltipText.replace("{0}", (Math.abs(int(param3 * 10)) / 10).toString());
      this.tooltipText = this.tooltipText.replace("{1}", (Math.abs(int(param4 * 10)) / 10).toString());
    }

    private function OnRaitingOver(param1:MouseEvent):void
    {
      var _loc2_:Point = this.localToGlobal(new Point());
      if (this.tooltipText.length == 0)
      {
        return;
      }
      dispatchEvent(new ButtonTooltipEvent(ButtonTooltipEvent.ACTION_TYPE_IN, this, _loc2_.x, _loc2_.y, this.tooltipText));
    }

    private function OnRaitingOut(param1:MouseEvent):void
    {
      if (this.tooltipText.length == 0)
      {
        return;
      }
      dispatchEvent(new ButtonTooltipEvent(ButtonTooltipEvent.ACTION_TYPE_OUT));
    }
  }
}
