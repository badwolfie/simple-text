using Gtk;

public class StTab : Box {
	public signal void view_drag_n_drop(string filename);

	private StTextEditor editor;

	public signal void close_clicked (StTab tab);
	public signal void tab_clicked (StTab tab, bool new_page);
	public signal void tab_focused (StTab tab);
	private string untitled = _("Untitled file");

	private SourceCompletion _completion;
	public SourceCompletion completion {
		get { return _completion; }
	}

	private StSourceView _text_view;
	public StSourceView text_view {
		get { return _text_view; }
	}

	private EventBox evt_box;
	private Label title_label;
	private EventBox close_button;

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

	private Label modified_buffer;
	public bool modified {
		get { return modified_buffer.get_visible(); }
		set { modified_buffer.set_visible(value); }
	}

	public StTab(StTextEditor editor) {
		Object();
		this.editor = editor;
		this.tab_title = untitled;
		this.width_request = 150;
		create_widgets(null);
	}

	public StTab.from_file
	(StTextEditor editor, string basename, string filename) {
		Object();
		this.editor = editor;
		this.tab_title = basename;
		create_widgets(filename);
	}

	private void create_widgets(string? filename) {
		this.orientation = Orientation.HORIZONTAL;
		this.spacing = 0;

		title_label = new Label(tab_title);
		var close_img = new Image.from_icon_name("window-close-symbolic",
			IconSize.MENU);
		title_label.ellipsize = Pango.EllipsizeMode.END;
		title_label.max_width_chars = 20;
		// title_label.width_chars = 20;
		title_label.show();
		
		close_button = new EventBox();
		close_button.child = close_img;
		close_button.set_above_child(true);
		close_button.button_press_event.connect(button_clicked);
		
		evt_box = new EventBox();
		evt_box.set_above_child(true);
		evt_box.button_press_event.connect(tab_clicked_action);

		pack_start(evt_box,true,true,0);
		pack_start(close_button,false,true,0);

		_text_view = new StSourceView(editor, filename);		
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

		var hbox = new Box(Orientation.HORIZONTAL,0);
		hbox.show();
		show_all();

		modified_buffer = new Label("<b> \xe2\x80\xa2</b>");
		modified_buffer.use_markup = true;
		modified_buffer.hide();

		hbox.pack_start(title_label,false,true,0);
		hbox.pack_start(modified_buffer,false,true,0);
		title_label.halign = Align.CENTER;
		hbox.halign = Align.CENTER;
		evt_box.child = hbox;
	}

	private void on_drag_n_drop(string filename) {
		view_drag_n_drop(filename);
	}

	public void refresh_title() {
		if(title_label != null) {
			title_label.use_markup = false;
			title_label.label = tab_title;
		}
	}

	private bool button_clicked(Gdk.EventButton evt) {
		this.close_clicked(this);
		return true;
	}

	private bool tab_clicked_action(Gdk.EventButton evt) {
		this.tab_clicked(this, false);
		mark_title();
		return true;
	}

	public void mark_title() {
		title_label.use_markup = true;
		title_label.label = "<span underline='single' font_weight='bold'>" + 
			tab_title + "</span>";
	}

	public void change_language(string language) {
		_text_view.change_language(language);
	}
}
