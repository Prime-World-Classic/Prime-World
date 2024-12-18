using System;
using System.Collections;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Drawing;
using System.Data;
using System.Windows.Forms;
using System.Windows.Forms.Design;

namespace EConTech.Windows.MACUI.Designer
{
	/// <summary>
	/// The Designer for the <see cref="MACTrackBar"/>.
	/// </summary>
	public class MACTrackBarDesigner : System.Windows.Forms.Design.ControlDesigner
	{
		public MACTrackBarDesigner()
		{}

		/// <summary>
		/// Returns the allowable design time selection rules.
		/// </summary>
		public override SelectionRules SelectionRules 
		{ 
			
			get 
			{ 
				MACTrackBar control = this.Control as MACTrackBar;

				// Disallow vertical or horizontal sizing when AutoSize = True
				if(control != null && control.AutoSize == true)
					if(control.Orientation == Orientation.Horizontal)
						return (base.SelectionRules & ~SelectionRules.TopSizeable) & ~SelectionRules.BottomSizeable;
					else //control.Orientation == Orientation.Vertical
						return (base.SelectionRules & ~SelectionRules.LeftSizeable) & ~SelectionRules.RightSizeable;
				else
					return base.SelectionRules;

			}
		}



		//Overrides
		/// <summary>
		/// Remove Button and Control properties that are 
		/// not supported by the <see cref="MACTrackBar"/>.
		/// </summary>
		protected override void PostFilterProperties(IDictionary Properties)
		{
			Properties.Remove("AllowDrop");
			Properties.Remove("BackgroundImage");
			Properties.Remove("ContextMenu");

			Properties.Remove("Text");
			Properties.Remove("TextAlign");
			Properties.Remove("RightToLeft");
		}


		//Overrides
		/// <summary>
		/// Remove Button and Control events that are 
		/// not supported by the <see cref="MACTrackBar"/>.
		/// </summary>
		protected override void PostFilterEvents(IDictionary events)
		{
			//Actions
			events.Remove("Click");
			events.Remove("DoubleClick");

			//Appearence
			events.Remove("Paint");

			//Behavior
			events.Remove("ChangeUICues");
            events.Remove("ImeModeChanged");
			events.Remove("QueryAccessibilityHelp");
			events.Remove("StyleChanged");
			events.Remove("SystemColorsChanged");

			//Drag Drop
			events.Remove("DragDrop");
			events.Remove("DragEnter");
			events.Remove("DragLeave");
			events.Remove("DragOver");
			events.Remove("GiveFeedback");
			events.Remove("QueryContinueDrag");
			events.Remove("DragDrop");

			//Layout
			events.Remove("Layout");
			events.Remove("Move");
			events.Remove("Resize");

			//Property Changed
			events.Remove("BackColorChanged");
			events.Remove("BackgroundImageChanged");
			events.Remove("BindingContextChanged");
			events.Remove("CausesValidationChanged");
			events.Remove("CursorChanged");
			events.Remove("FontChanged");
			events.Remove("ForeColorChanged");
			events.Remove("RightToLeftChanged");
			events.Remove("SizeChanged");
			events.Remove("TextChanged");
			
			base.PostFilterEvents (events);
		}

	}
}