using Gtk;

public class StSourceView : SourceView {
	public signal void buffer_modified (bool modified);
	public signal void drag_n_drop (string filename);

	public signal void file_saved ();
	public signal void file_loaded ();
	private bool insert_matching_braces;
	
	private SourceSearchSettings _search_settings;
	public SourceSearchSettings search_settings {
		get { return _search_settings; }
	}

	private SourceFile _source_file;
	public SourceFile source_file {
		get { return _source_file; }
	}

	private SourceFileSaver file_saver;
	private SourceFileLoader file_loader;

	private const int TARGET_TYPE_URI_LIST = 80;
	private const TargetEntry[] target_list = {
		{ "text/uri-list", 0, TARGET_TYPE_URI_LIST }
	};

	private StTextEditor editor;

	public StSourceView (StTextEditor editor, string? filename) {
		Object();
		this.editor = editor;
		
		_source_file = new SourceFile();
		if (filename != null)
			source_file.location = File.new_for_path(filename);

		load_view_format();
		connect_signals();
		set_properties();
	}

	private void load_view_format () {
		file_loader = new SourceFileLoader(
			buffer as SourceBuffer, 
			this.source_file
		);

		file_saver = new SourceFileSaver(
			buffer as SourceBuffer, 
			this.source_file
		);

		var scheme_manager = SourceStyleSchemeManager.get_default();
		var source_scheme = scheme_manager.get_scheme(editor.color_scheme);

		(buffer as SourceBuffer).style_scheme = source_scheme;
		(buffer as SourceBuffer).highlight_syntax = true;
		load_file();
	}

	private void load_file () { 
		if (source_file.location != null) {
			file_loader.load_async(Priority.DEFAULT, null, null);
			
			bool result_uncertain;
			string content_type = ContentType.guess(
				source_file.location.get_path(), 
				this.buffer.text.data, 
				out result_uncertain
			);
			
			if (result_uncertain) content_type = null;
			var lang_manager = SourceLanguageManager.get_default();
			var source_lang = lang_manager.guess_language(
				source_file.location.get_path(), content_type
			);

			(buffer as SourceBuffer).language = source_lang;
			buffer.set_modified(false);
			file_loaded();
		}
	}

	public void save_file (File? target) {
		if ((source_file.location == null) && (target != null)) {
			_source_file.location = target;

			bool result_uncertain;
			string content_type = ContentType.guess(
				source_file.location.get_path(), 
				this.buffer.text.data, 
				out result_uncertain
			);
			
			if (result_uncertain) content_type = null;
			var lang_manager = SourceLanguageManager.get_default();
			var source_lang = lang_manager.guess_language(
				source_file.location.get_path(), content_type
			);

			(buffer as SourceBuffer).language = source_lang;
		}

		file_saver.save_async(Priority.DEFAULT, null, null);
		buffer.set_modified(false);
		file_saved();
	}

	private void set_properties () {
		show_line_numbers = editor.show_line_numbers;
		show_right_margin = editor.show_right_margin;
		right_margin_position = editor.right_margin_at;
		highlight_current_line = editor.highlight_current_line;
		(buffer as SourceBuffer).highlight_matching_brackets = 
			editor.highlight_brackets;
		insert_matching_braces = editor.insert_braces;
		
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
		
		_search_settings = new SourceSearchSettings();
		_search_settings.at_word_boundaries = false;
		_search_settings.case_sensitive = false;
		_search_settings.regex_enabled = false;
		_search_settings.search_text = null;
		_search_settings.wrap_around = true;
		
		drag_data_received.connect(on_drag_data_received);
		buffer.insert_text.connect_after(brace_insert);
	}

	public void change_language (string language) {
		var lang_manager = SourceLanguageManager.get_default();
		var source_lang = lang_manager.get_language(language);
		(buffer as SourceBuffer).language = source_lang;
		buffer.set_modified(false);
	}

	private void connect_signals () {
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

			var source_scheme = scheme_manager.get_scheme(editor.color_scheme);
			(this.buffer as SourceBuffer).style_scheme = source_scheme;
		});
		
		editor.notify["insert-braces"].connect((pspec) => {
			insert_matching_braces = editor.insert_braces;
		});

		buffer.modified_changed.connect(on_buffer_changes);
	}

	private void on_buffer_changes () {
		buffer_modified(buffer.get_modified());
	}

	private void on_drag_data_received (Widget widget, Gdk.DragContext context, 
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

	private string get_file_path_from_uri (string uri) {
		string path = "";

		if (uri.has_prefix("file://")) {
			path = uri.substring("file://".length);
		} else if (uri.has_prefix("file:")) {
			path = uri.substring("file:".length);
		}

		path = path.strip();
		return path;
	}
	
	public string get_language_name () {
		string language = null;
		if ((this.buffer as SourceBuffer).language != null)
			language = (this.buffer as SourceBuffer).language.name;
		return language;
	}
	
	public SourceBuffer get_source_buffer () {
		return (this.buffer as SourceBuffer);
	}
	
	private void brace_insert (ref TextIter location, string text, int len) {
		bool is_open_brace = true;
		// bool is_close_brace = false;
		string insert = "";
		
		switch (text[len - 1]) {
			case '{':
				insert = "}";
				break;
			case '[':
				insert = "]";
				break;
			case '(':
				insert = ")";
				break;
			default:
				is_open_brace = false;
				break;
		}
		
		TextIter iter;
		if (is_open_brace && insert_matching_braces) {
			buffer.insert(ref location, insert, insert.length);
			buffer.get_iter_at_offset(out iter, buffer.cursor_position - 1);
			buffer.place_cursor(iter);
		}
	}
}

