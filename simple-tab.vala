using Gtk;

public class SimpleTab : Box {
	public signal void close_clicked (Widget tab_widget);
	private string untitled = "Untitled";

	private Label title_label;
	private Button close_button;

	private Widget _tab_widget;
	public Widget tab_widget {
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

	public SimpleTab() {
		Object();
		this.tab_title = untitled;
		create_widgets(null,null);
	}

	public SimpleTab.from_file(string base_name, string file_path) {
		Object();
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
		this.spacing = 100;

		title_label = new Label(tab_title);
		close_button = new Button.from_icon_name("gtk-close",IconSize.MENU);
		close_button.clicked.connect(button_clicked);

		pack_start(title_label,true,true,0);
		pack_start(close_button,true,true,0);

		SimpleSourceView text_view;
		if (display_text != null) {
			if (language != null) {
				text_view = 
					new SimpleSourceView.with_language(language,display_text);
			} else 
				text_view = new SimpleSourceView.with_text(display_text);
		} else
			text_view = new SimpleSourceView();
		text_view.show();
        
		var tab_widget = new ScrolledWindow(null,null);
		tab_widget.set_policy(PolicyType.AUTOMATIC,PolicyType.AUTOMATIC);
		tab_widget.add(text_view);
		tab_widget.show();

		this.tab_widget = tab_widget;

		show_all();
	}

	private void refresh_title() {
		if(title_label != null)
			title_label.label = tab_title;
	}

	private void button_clicked() {
		this.close_clicked(this.tab_widget);
	}
}