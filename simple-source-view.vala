using Gtk;

public class SimpleSourceView : SourceView {
	public SimpleSourceView() {
		Object();
		set_properties();
		grab_focus();
	}

	private void set_properties() {
		override_font(Pango.FontDescription.from_string("monospace 11"));
		smart_home_end = SourceSmartHomeEndType.BEFORE;
		wrap_mode = WrapMode.NONE;
		show_line_numbers = true;
		auto_indent = true;
		tab_width = 4;	
	}
}