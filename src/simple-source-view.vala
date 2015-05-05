using Gtk;

public class SimpleSourceView : SourceView {
	public signal void drag_n_drop(string file_name);

	private const int TARGET_TYPE_URI_LIST = 80;
	private const TargetEntry[] target_list = {
		{ "text/uri-list", 0, TARGET_TYPE_URI_LIST }
	};

	private TextEditor editor;

	public SimpleSourceView(TextEditor editor) {
		var buff = new SourceBuffer(null);
		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("/opt/simple-text/style_schemes");
		var source_scheme = scheme_manager.get_scheme(editor.color_scheme);

		buff.style_scheme = source_scheme;
		Object(buffer: buff);
		this.editor = editor;
		connect_signals();
		set_properties();
		
		buff.set_modified(false);
	}

	public SimpleSourceView.with_text(TextEditor editor, string display_text) {
		var buff = new SourceBuffer(null);
		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("/opt/simple-text/style_schemes");
		var source_scheme = scheme_manager.get_scheme(editor.color_scheme);

		buff.style_scheme = source_scheme;
		buff.text = display_text;

		Object(buffer: buff);
		this.editor = editor;
		connect_signals();
		set_properties();
		
		buff.set_modified(false);
	}

	public SimpleSourceView.with_language(
		TextEditor editor, string language, string display_text) {

		var lang_manager = SourceLanguageManager.get_default();
		var source_lang = lang_manager.get_language(language);
		var buff = new SourceBuffer.with_language(source_lang);

		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("/opt/simple-text/style_schemes");
		var source_scheme = scheme_manager.get_scheme(editor.color_scheme);

		buff.style_scheme = source_scheme;
		buff.highlight_syntax = true;
		buff.text = display_text;

		Object(buffer: buff);
		this.editor = editor;
		connect_signals();
		set_properties();
		
		buff.set_modified(false);
	}

	private void set_properties() {
		show_line_numbers = editor.show_line_numbers;
		show_right_margin = editor.show_right_margin;
		right_margin_position = editor.right_margin_at;
		highlight_current_line = editor.highlight_current_line;
		(buffer as SourceBuffer).highlight_matching_brackets = 
			editor.highlight_brackets;
		
		tab_width = editor.tab_width;
		insert_spaces_instead_of_tabs = editor.insert_spaces;
		auto_indent = editor.auto_indent;
		
		override_font(Pango.FontDescription.from_string(editor.editor_font));
		
		if (editor.show_grid_pattern)
			set_background_pattern(SourceBackgroundPatternType.GRID);
		else
			set_background_pattern(SourceBackgroundPatternType.NONE);

		smart_home_end = SourceSmartHomeEndType.BEFORE;
		wrap_mode = WrapMode.NONE;

		drag_dest_set(this,
			DestDefaults.MOTION 
			| DestDefaults.HIGHLIGHT 
			| DestDefaults.DROP,
			target_list,
			Gdk.DragAction.COPY
		);

		drag_data_received.connect(on_drag_data_received);
	}

	public void change_language(string language) {
		var lang_manager = SourceLanguageManager.get_default();
		var source_lang = lang_manager.get_language(language);
		var buff = new SourceBuffer.with_language(source_lang);

		var scheme_manager = SourceStyleSchemeManager.get_default();
		scheme_manager.append_search_path("/opt/simple-text/style_schemes");
		var source_scheme = scheme_manager.get_scheme(editor.color_scheme);

		buff.highlight_matching_brackets = editor.highlight_brackets;
		buff.style_scheme = source_scheme;
		buff.highlight_syntax = true;

		buff.text = this.buffer.text;
		this.buffer = buff;

		set_properties();

		buff.set_modified(false);
	}

	private void connect_signals() {
		editor.notify["show-line-numbers"].connect((pspec) => {
			show_line_numbers = editor.show_line_numbers;
		});
		
		editor.notify["show-right-margin"].connect((pspec) => {
			show_right_margin = editor.show_right_margin;
		});
		
		editor.notify["right-margin-at"].connect((pspec) => {
			right_margin_position = editor.right_margin_at;
		});
		
		editor.notify["highlight-current-line"].connect((pspec) => {
			highlight_current_line = editor.highlight_current_line;
		});
		
		editor.notify["highlight-brackets"].connect((pspec) => {
			(buffer as SourceBuffer).highlight_matching_brackets = 
				editor.highlight_brackets;
		});
		
		editor.notify["tab-width"].connect((pspec) => {
			tab_width = editor.tab_width;
		});
		
		editor.notify["insert-spaces"].connect((pspec) => {
			insert_spaces_instead_of_tabs = editor.insert_spaces;
		});
		
		editor.notify["auto-indent"].connect((pspec) => {
			auto_indent = editor.auto_indent;
		});

		editor.notify["show-grid-pattern"].connect((pspec) => {
			if (editor.show_grid_pattern)
				set_background_pattern(SourceBackgroundPatternType.GRID);
			else
				set_background_pattern(SourceBackgroundPatternType.NONE);
		});
		
		editor.notify["use-default-typo"].connect((pspec) => {
			if (editor.use_default_typo) {
				override_font(
					Pango.FontDescription.from_string("Monospace 10"));
			} else {
				override_font(
					Pango.FontDescription.from_string(editor.editor_font));
			}
		});
		
		editor.notify["editor-font"].connect((pspec) => {
			override_font(
				Pango.FontDescription.from_string(editor.editor_font));
		});

		editor.notify["color-scheme"].connect((pspec) => {
			var scheme_manager = SourceStyleSchemeManager.get_default();
			scheme_manager.append_search_path("/opt/simple-text/style_schemes");

			var source_scheme = scheme_manager.get_scheme(editor.color_scheme);
			(this.buffer as SourceBuffer).style_scheme = source_scheme;
		});
	}

	private void on_drag_data_received(Widget widget, Gdk.DragContext context, 
									   int x, int y, 
									   SelectionData selection_data, 
									   uint target_type, uint time) {
		if (target_type == TARGET_TYPE_URI_LIST) {
			var uri_list = ((string) selection_data.get_data()).strip();

			var uris = uri_list.split("\n");
			foreach (var uri in uris) {
				string path = get_file_path_from_uri(uri);
				drag_n_drop(path);
			}
		}
	}

	private string get_file_path_from_uri(string uri) {
		string path = "";

		if (uri.has_prefix("file://")) {
			path = uri.substring("file://".length);
		} else if (uri.has_prefix("file:")) {
			path = uri.substring("file:".length);
		}

		path = path.strip();
		return path;
	}
}
