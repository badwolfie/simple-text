using Gtk;

public class SimpleSourceView : SourceView {

	public SimpleSourceView() {
		var buff = new SourceBuffer(null);
		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("./style_schemes");
		var source_scheme = scheme_manager.get_scheme("monokai-extended");
		
		buff.style_scheme = source_scheme;
		Object(buffer: buff);
		set_properties();

		buff.set_modified(false);
	}

	public SimpleSourceView.with_text(string display_text) {
		var buff = new SourceBuffer(null);
		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("./style_schemes");
		var source_scheme = scheme_manager.get_scheme("monokai-extended");

		buff.style_scheme = source_scheme;
		buff.text = display_text;

		Object(buffer: buff);
		set_properties();

		buff.set_modified(false);
	}

	public SimpleSourceView.with_language(
		string language, string display_text) {

		var lang_manager = SourceLanguageManager.get_default();
		var source_lang = lang_manager.get_language(language);
		var buff = new SourceBuffer.with_language(source_lang);

		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("./style_schemes");
		var source_scheme = scheme_manager.get_scheme("monokai-extended");

		buff.highlight_matching_brackets = true;
		buff.style_scheme = source_scheme;
		buff.highlight_syntax = true;
		buff.text = display_text;

		Object(buffer: buff);
		set_properties();

		buff.set_modified(false);
	}

	private void set_properties() {
		override_font(Pango.FontDescription.from_string("Liberation Mono 12"));
		smart_home_end = SourceSmartHomeEndType.BEFORE;
		wrap_mode = WrapMode.NONE;
		show_line_numbers = true;
		auto_indent = true;
		tab_width = 4;
	}

	public void change_language(string language) {
		var lang_manager = SourceLanguageManager.get_default();
		var source_lang = lang_manager.get_language(language);
		var buff = new SourceBuffer.with_language(source_lang);

		buff.text = this.buffer.text;
		this.buffer = buff;

		this.buffer.set_modified(false);
	}
}