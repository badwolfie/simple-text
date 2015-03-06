using Gtk;

public enum OPERATION {
	NEW_FILE,
	OPEN_FILE,
	EDIT_FILE,
	SAVE_FILE,
	CLOSE_FILE
}

public class MainWindow : ApplicationWindow {
	private string untitled = "Untitled";
	private List<string> opened_files;
	private Array<string> closed_files;

	private SimpleHeaderBar headerbar;
	private Statusbar status;
	private Notebook panel;

	private SearchEntry search_entry;
	private SearchBar search_bar;
	private Button previous_search;
	private Button next_search;
	private uint context_id;

	public MainWindow(Gtk.Application app) {
		Object(application: app);
		opened_files = new List<string>();
		closed_files = new Array<string>();

		window_position = WindowPosition.CENTER;
		set_default_size(1000,700);
		border_width = 0;

		create_widgets();
	}

	private void create_widgets() {
		Gtk.Settings.get_default().set(
			"gtk-application-prefer-dark-theme",true);

		headerbar = new SimpleHeaderBar(this);
		set_titlebar(headerbar);
		headerbar.show();

		var action_re_open = new SimpleAction("re_open",null);
		action_re_open.activate.connect(re_open_cb);
		add_action(action_re_open);

		var action_save_as = new SimpleAction("save_as",null);
		action_save_as.activate.connect(save_as_cb);
		add_action(action_save_as);

		var action_close_tab = new SimpleAction("close_tab",null);
		action_close_tab.activate.connect(close_tab_cb);
		add_action(action_close_tab);

		var action_search_mode = new SimpleAction("search_mode",null);
		action_search_mode.activate.connect(search_mode_cb);
		add_action(action_search_mode);

		var action_lines = new SimpleAction("toggle_lines",null);
		action_lines.activate.connect(toggle_lines_cb);
		add_action(action_lines);

		search_entry = new SearchEntry();
		search_entry.placeholder_text = "Enter your search...";
		search_entry.set_width_chars(60);

		search_entry.search_changed.connect(search_stuff_next);
		search_entry.activate.connect(search_stuff_next);
		search_entry.show();

		next_search = new Button.from_icon_name(
			"go-down-symbolic",IconSize.MENU);
		next_search.clicked.connect(search_stuff_next);
		next_search.show();

		previous_search = new Button.from_icon_name(
			"go-up-symbolic",IconSize.MENU);
		previous_search.clicked.connect(search_stuff_prev);
		previous_search.show();

		var hbox = new Box(Orientation.HORIZONTAL,5);
		hbox.pack_start(search_entry,false,false,0);
		hbox.pack_start(previous_search,false,false,0);
		hbox.pack_start(next_search,false,false,0);
		hbox.show();

		search_bar = new SearchBar();
		search_bar.connect_entry(search_entry);
		search_bar.add(hbox);
		search_bar.show();

		panel = new Notebook();
		panel.switch_page.connect((page,page_num) => {
			var box = panel.get_tab_label(page) as Box;
			var label = box.get_children().first().data as Label;
			headerbar.title = label.label;
		});

		status = new Statusbar();
		context_id = status.get_context_id("status");
		status.show();

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(search_bar,false,true,0);
		vbox.pack_start(panel,true,true,0);
		vbox.pack_start(status,false,true,0);
		vbox.show();

		panel.scrollable = true;
		opened_files.append(untitled);
		add_new_tab();
		
		panel.show();
		add(vbox);
	}

	public void add_new_tab_from_file() {
		var file_chooser = new FileChooserDialog("Open File", this,
			FileChooserAction.OPEN,
			"Cancel", ResponseType.CANCEL,
			"Open", ResponseType.ACCEPT
		);

		if (file_chooser.run() == ResponseType.ACCEPT) {
			var tab_label = new SimpleTab.from_file(
				file_chooser.get_file().get_basename(),
				file_chooser.get_filename());
			var tab_widget = tab_label.tab_widget;
			
			tab_label.close_clicked.connect((page) => {
				int page_n = panel.page_num(page);

				if (confirm_close(page_n)) {
					if (opened_files.nth_data(page_n) != untitled)
						closed_files.append_val(opened_files.nth_data(page_n));

					opened_files.remove(opened_files.nth_data(page_n));
					panel.remove_page(page_n);
					check_pages();
				}
			});
			
			panel.append_page(tab_widget,tab_label);
			var view = (tab_widget as ScrolledWindow).get_child() as SourceView;
			view.key_release_event.connect(changes_done);

			panel.set_show_tabs(panel.get_n_pages() != 1);
			panel.set_tab_reorderable(tab_widget,true);
			headerbar.set_title(file_chooser.get_file().get_basename());
			
			panel.next_page();
			opened_files.insert(file_chooser.get_filename(),
						panel.get_current_page());

			refresh_statusbar(OPERATION.OPEN_FILE);
		}

		file_chooser.destroy();
	}

	public void save_tab_to_file() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if (opened_files.nth_data(panel.get_current_page()) == untitled) {
			if (view.buffer.text == "") return;

			var file_chooser = new FileChooserDialog("Save File", this,
				FileChooserAction.SAVE,
				"Cancel", ResponseType.CANCEL,
				"Save", ResponseType.ACCEPT
			);

			switch (file_chooser.run()) {
				default:
					break;
				case ResponseType.ACCEPT:
					var tab_label = panel.get_tab_label(page) as SimpleTab;
					tab_label.tab_title = 
						file_chooser.get_file().get_basename();
					headerbar.set_title(file_chooser.get_file().get_basename());
					save_file(view,file_chooser.get_filename());

					opened_files.remove(opened_files.nth_data(
						panel.get_current_page()));
					opened_files.insert(file_chooser.get_filename(),
						panel.get_current_page());
					reset_changes(tab_label);
					break;
			}

			file_chooser.destroy();
		} else {
			string file_name = opened_files.nth_data(panel.get_current_page());
			save_file(view,file_name);
			reset_changes(panel.get_tab_label(page) as SimpleTab);
		}
	}

	private void save_as_cb() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		var file_chooser = new FileChooserDialog("Save File", this,
			FileChooserAction.SAVE,
			"Cancel", ResponseType.CANCEL,
			"Save", ResponseType.ACCEPT
		);

		switch (file_chooser.run()) {
			case ResponseType.ACCEPT:
				var tab_label = panel.get_tab_label(page) as SimpleTab;
				tab_label.tab_title = file_chooser.get_file().get_basename();
				headerbar.set_title(file_chooser.get_file().get_basename());
				save_file(view,file_chooser.get_filename());

				opened_files.remove(opened_files.nth_data(panel.get_current_page()));
				opened_files.insert(file_chooser.get_filename(),
					panel.get_current_page());
				reset_changes(tab_label);
				break;
			default:
				break;
		}

		file_chooser.destroy();
	}

	public void new_tab_cb() {
		add_new_tab();
		opened_files.append(untitled);
		panel.next_page();
	}

	public void build_code() {
		Posix.system("ls");
	}

	private void re_open_cb() {
		if (closed_files.length == 0) return;

		string last_file_path = closed_files.data[closed_files.length - 1];
		string last_file_basename = File.new_for_path(last_file_path).get_basename();
		closed_files.remove_index(closed_files.length - 1);

		var tab_label = new SimpleTab.from_file(
			last_file_basename,
			last_file_path);
		var tab_widget = tab_label.tab_widget;
		
		tab_label.close_clicked.connect((page) => {
			int page_n = panel.page_num(page);

			if (confirm_close(page_n)) {
				if (opened_files.nth_data(page_n) != untitled)
					closed_files.append_val(opened_files.nth_data(page_n));

				opened_files.remove(opened_files.nth_data(page_n));
				panel.remove_page(page_n);
				check_pages();
			}
		});
		
		panel.append_page(tab_widget,tab_label);
		var view = (tab_widget as ScrolledWindow).get_child() as SourceView;
		view.key_release_event.connect(changes_done);

		panel.set_show_tabs(panel.get_n_pages() != 1);
		panel.set_tab_reorderable(tab_widget,true);
		headerbar.set_title(last_file_basename);
		
		panel.next_page();
		opened_files.insert(last_file_path,panel.get_current_page());

		refresh_statusbar(OPERATION.OPEN_FILE);
	}

	private void search_mode_cb() {
		search_bar.search_mode_enabled = !search_bar.search_mode_enabled;
	}

	private void close_tab_cb() {
		int page = panel.get_current_page();
		if ((panel.get_n_pages() > 0) && confirm_close(page)) {
			refresh_statusbar(OPERATION.CLOSE_FILE);

			if (opened_files.nth_data(page) != untitled)
				closed_files.append_val(opened_files.nth_data(page));
			
			opened_files.remove(opened_files.nth_data(page));
			panel.remove_page(page);
			check_pages();
		}
	}

	private void toggle_lines_cb() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;
		view.show_line_numbers = !view.show_line_numbers;
	}

	private void search_stuff_next() {
		stdout.printf("Next\n");
		// TextIter.forward_search(search_entry.text,TextSearchFlags.TEXT_ONLY,null,null,null);
	}

	private void search_stuff_prev() {
		stdout.printf("Previous\n");
	}

	private void check_pages() {
		panel.set_show_tabs(panel.get_n_pages() != 1);
		
		if (panel.get_n_pages() == 0)
			headerbar.title = "Simple Text";
	}

	private void refresh_statusbar(OPERATION operation) {
		status.pop(context_id);
		string file_name = opened_files.nth_data(panel.get_current_page());
		
		switch (operation) {
			case OPERATION.NEW_FILE:
				status.push(
					context_id,
					"New file");
				break;
			case OPERATION.OPEN_FILE:
				status.push(
					context_id,
					"Opened " + file_name);
				break;
			case OPERATION.EDIT_FILE:
				status.push(
					context_id,
					"Editing...");
				break;
			case OPERATION.SAVE_FILE:
				status.push(
					context_id,
					"Saved " + file_name);
				break;
			case OPERATION.CLOSE_FILE:
				status.push(
					context_id,
					"Closed " + file_name);
				break;
		}
	}

	private bool changes_done(Gdk.EventKey event) {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if (view.buffer.get_modified()) {
			var tab_label = panel.get_tab_label(page) as SimpleTab;

			if (!headerbar.title.contains("*"))
				headerbar.title = "*" + headerbar.title;
			if (!tab_label.tab_title.contains("*"))
				tab_label.tab_title = "*" + tab_label.tab_title;
			
			refresh_statusbar(OPERATION.EDIT_FILE);

			return false;
		}
		
		return true;
	}

	private void reset_changes(SimpleTab tab_label) {
		if (headerbar.title.contains("*"))
			headerbar.title = headerbar.title.replace("*","");
		if (tab_label.tab_title.contains("*"))
			tab_label.tab_title = tab_label.tab_title.replace("*","");
	}

	private void add_new_tab() {
		var tab_label = new SimpleTab();
		var tab_widget = tab_label.tab_widget;

		tab_label.close_clicked.connect((tab_widget) => {
			int page = panel.page_num(tab_widget);

			if (confirm_close(page)) {
				if(opened_files.nth_data(page) != untitled)
					closed_files.append_val(opened_files.nth_data(page));

				opened_files.remove(opened_files.nth_data(page));
				panel.remove_page(page);
				check_pages();
			}
		});

		panel.append_page(tab_widget,tab_label);
		var view = (tab_widget as ScrolledWindow).get_child() as SourceView;
		view.key_release_event.connect(changes_done);

		panel.set_show_tabs(panel.get_n_pages() != 1);
		panel.set_tab_reorderable(tab_widget,true);
		headerbar.set_title(untitled);

		refresh_statusbar(OPERATION.NEW_FILE);
	}

	private void save_file(SourceView view,string filename) {
		try {
			FileUtils.set_contents(filename,view.buffer.text);
			view.buffer.set_modified(false);
			refresh_statusbar(OPERATION.SAVE_FILE);
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	private bool confirm_close(int page) {
		if ((panel.get_tab_label(panel.get_nth_page(page)) 
			as SimpleTab).tab_title.contains("*")) {
			panel.page = page;

			var confirmar = new ConfirmExit();
			confirmar.set_transient_for(this);

			switch (confirmar.run()) {
				default:
				case ResponseType.CANCEL:
					confirmar.destroy();
					return false;
				case ResponseType.ACCEPT:
					break;
				case ResponseType.APPLY:
					save_tab_to_file();
					break;
			}

			confirmar.destroy();
		}

		return true;
	}
}
