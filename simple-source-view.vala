using Gtk;

public class SimpleSourceView : SourceView {
	public SimpleSourceView() {
		Object();
		set_properties();
	}

	public SimpleSourceView.with_text(string display_text) {
		var buff = new SourceBuffer(null);
		buff.text = display_text;
		buff.set_modified(false);

		Object(buffer: buff);
		set_properties();
	}

	private void set_properties() {
		override_font(Pango.FontDescription.from_string("Liberation Mono 11"));
		smart_home_end = SourceSmartHomeEndType.BEFORE;
		wrap_mode = WrapMode.NONE;
		show_line_numbers = true;
		auto_indent = true;
		tab_width = 4;
	}
}