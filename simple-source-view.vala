using Gtk;

public class SimpleSourceView : SourceView {
	private bool _syntax;
	public bool syntax {
		get { return _syntax; }
	}

	public SimpleSourceView() {
		Object();
		_syntax = false;
		set_properties();
	}

	public SimpleSourceView.with_text(string display_text) {
		var buff = new SourceBuffer(null);
		buff.text = display_text;
		buff.set_modified(false);

		Object(buffer: buff);
		_syntax = false;
		set_properties();
	}

	public SimpleSourceView.with_language(
		string language, string display_text) {
		var source_manager = SourceLanguageManager.get_default();
		var source_lang = source_manager.get_language(language);

		var buff = new SourceBuffer.with_language(source_lang);
		buff.highlight_matching_brackets = true;
		buff.highlight_syntax = true;
		buff.text = display_text;
		buff.set_modified(false);

		Object(buffer: buff);
		_syntax = true;
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