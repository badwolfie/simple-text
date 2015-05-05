using Gtk;

public class SimpleTab : Box {
	public signal void view_drag_n_drop(string file_name);

	private TextEditor editor;

	public signal void close_clicked (SimpleTab tab);
	public signal void tab_clicked (SimpleTab tab);
	public signal void tab_focused (SimpleTab tab);
	private string untitled = _("Untitled file");

	private SourceCompletion _completion;
	public SourceCompletion completion {
		get { return _completion; }
	}

	private SimpleSourceView _text_view;
	public SimpleSourceView text_view {
		get { return _text_view; }
	}

	private EventBox evt_box;
	private Label title_label;
	private Button close_button;
	private Separator separator;

	private ScrolledWindow _tab_widget;
	public ScrolledWindow tab_widget {
		get { return _tab_widget; }
		set { _tab_widget = value; }
	}

	private string _tab_title;
	public string tab_title {
		get { return _tab_title; }
		set {
			if(_tab_title == value)
				return;
			_tab_title = value;

			refresh_title();
		}
	}

	public SimpleTab(TextEditor editor) {
		Object();
		this.editor = editor;
		this.tab_title = untitled;
		create_widgets(null,null);
	}

	public SimpleTab.from_file(TextEditor editor, string base_name, string file_path) {
		Object();
		this.editor = editor;
		this.tab_title = base_name;

		try {
			string text;
			FileUtils.get_contents(file_path, out text);
			var plangs = new ProgrammingLanguages();
			create_widgets(plangs.get_lang_id(base_name),text);
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	private void create_widgets(string? language, string? display_text) {
		this.orientation = Orientation.HORIZONTAL;
		this.spacing = 0;

		title_label = new Label(tab_title);
		separator = new Separator(Orientation.VERTICAL);
		close_button = new Button.from_icon_name("window-close-symbolic",
												 IconSize.MENU);
		close_button.clicked.connect(button_clicked);
		
		evt_box = new EventBox();
		evt_box.child = title_label;
		evt_box.set_above_child(true);
		evt_box.button_press_event.connect(tab_clicked_action);

		pack_start(evt_box,true,true,0);
		pack_start(close_button,false,true,5);
		pack_start(separator,false,true,0);

		if (display_text != null) {
			if (language != null) {
				_text_view = new SimpleSourceView.with_language(
					editor,language,display_text);
			} else {
				_text_view = 
					new SimpleSourceView.with_text(editor,display_text);
			}
		} else
			_text_view = new SimpleSourceView(editor);
		_text_view.drag_n_drop.connect(on_drag_n_drop);
		text_view.show();

		_completion = text_view.get_completion();
		completion.select_on_show = true;
		completion.show_headers = true;
		completion.show_icons = true;
        
		_tab_widget = new ScrolledWindow(null,null);
		tab_widget.set_policy(PolicyType.AUTOMATIC,PolicyType.AUTOMATIC);
		tab_widget.add(text_view);
		tab_widget.show();

		show_all();
	}

	private void on_drag_n_drop(string file_name) {
		view_drag_n_drop(file_name);
	}

	public void refresh_title() {
		if(title_label != null) {
			title_label.use_markup = false;
			title_label.label = tab_title;
		}
	}

	private void button_clicked() {
		this.close_clicked(this);
	}

	private bool tab_clicked_action(Gdk.EventButton evt) {
		this.tab_clicked(this);
		mark_title();
		return true;
	}

	public void mark_title() {
		title_label.use_markup = true;
		title_label.label = "<b>" + tab_title + "</b>";
	}

	public void change_language(string language) {
		_text_view.change_language(language);
	}
}
