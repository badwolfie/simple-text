using Gtk;

public class MainWindow : ApplicationWindow {
	private string untitled = "Untitled";
	private Array<string> closed_files;
	private List<string> opened_files;

	private SimpleHeaderBar headerbar;
	private SimpleStatusbar status;
	private Notebook panel;

	private SearchEntry search_entry;
	private SearchBar search_bar;
	private Button previous_search;
	private Button next_search;

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

		var action_next_tab = new SimpleAction("next_tab",null);
		action_next_tab.activate.connect(next_tab_cb);
		add_action(action_next_tab);

		var action_prev_tab = new SimpleAction("prev_tab",null);
		action_prev_tab.activate.connect(prev_tab_cb);
		add_action(action_prev_tab);

		var action_close_tab = new SimpleAction("close_tab",null);
		action_close_tab.activate.connect(close_tab_cb);
		add_action(action_close_tab);

		var action_search_mode = new SimpleAction("search_mode",null);
		action_search_mode.activate.connect(search_mode_cb);
		add_action(action_search_mode);

		var action_lines = new SimpleAction("toggle_lines",null);
		action_lines.activate.connect(toggle_lines_cb);
		add_action(action_lines);

		var action_quit = new SimpleAction("quit_window",null);
		action_quit.activate.connect(quit_cb);
		add_action(action_quit);		

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
			status.refresh_language(label.label);

			var p_langs = new ProgrammingLanguages();
			headerbar.buildable = p_langs.is_buildable(label.label);
		});

		status = new SimpleStatusbar(this);
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

					string f_name = opened_files.nth_data(page_n);
					opened_files.remove(opened_files.nth_data(page_n));
					panel.remove_page(page_n);

					status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);
					check_pages();
				}
			});
			
			panel.append_page(tab_widget,tab_label);
			var view = (tab_widget as ScrolledWindow).get_child() as SourceView;
			view.key_release_event.connect(changes_done);
			view.buffer.set_modified(false);

			panel.set_show_tabs(panel.get_n_pages() != 1);
			panel.set_tab_reorderable(tab_widget,true);
			headerbar.set_title(file_chooser.get_file().get_basename());
			
			panel.next_page();
			opened_files.insert(file_chooser.get_filename(),
						panel.get_current_page());

			string f_name = opened_files.nth_data(panel.get_current_page());
			status.refresh_statusbar(FileOpeartion.OPEN_FILE,f_name);
			status.refresh_language(f_name);
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

			var p_langs = new ProgrammingLanguages();
			string ext = p_langs.get_lang_ext(status.label.label);
			file_chooser.set_current_name(untitled + ext);

			switch (file_chooser.run()) {
				default:
					break;
				case ResponseType.ACCEPT:
					var tab_label = panel.get_tab_label(page) as SimpleTab;
					tab_label.tab_title = 
						file_chooser.get_file().get_basename();
					headerbar.set_title(file_chooser.get_file().get_basename());
					save_file(view,file_chooser.get_filename());

					tab_label = new SimpleTab.from_file(
						file_chooser.get_file().get_basename(),
						file_chooser.get_filename());
					var tab_widget = tab_label.tab_widget;

					view = (tab_widget as ScrolledWindow).get_child() 
						as SourceView;
					view.key_release_event.connect(changes_done);

					int current_page = panel.get_current_page();
					panel.remove_page(current_page);
					panel.insert_page(tab_widget,tab_label,current_page);

					opened_files.remove(opened_files.nth_data(current_page));
					opened_files.insert(file_chooser.get_filename(),
						current_page);
					reset_changes(tab_label);
					break;
			}

			file_chooser.destroy();
		} else if (headerbar.title.contains("*")) {
			string file_name = opened_files.nth_data(panel.get_current_page());
			save_file(view,file_name);
			reset_changes(panel.get_tab_label(page) as SimpleTab);
		}
	}

	private void save_as_cb() {
		string filename = opened_files.nth_data(panel.get_current_page());
		if ((filename == untitled) || (filename == ("*" + untitled))) return;

		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		var file_chooser = new FileChooserDialog("Save File", this,
			FileChooserAction.SAVE,
			"Cancel", ResponseType.CANCEL,
			"Save", ResponseType.ACCEPT
		);

		int index = filename.last_index_of("/");
		file_chooser.set_current_name(filename.substring(index + 1));

		switch (file_chooser.run()) {
			case ResponseType.ACCEPT:
				var tab_label = panel.get_tab_label(page) as SimpleTab;
				tab_label.tab_title = file_chooser.get_file().get_basename();
				headerbar.set_title(file_chooser.get_file().get_basename());
				save_file(view,file_chooser.get_filename());

				tab_label = new SimpleTab.from_file(
					file_chooser.get_file().get_basename(),
					file_chooser.get_filename());

				opened_files.remove(
					opened_files.nth_data(panel.get_current_page()));
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
	}

	public void build_code() {
		save_tab_to_file();
		status.refresh_statusbar(FileOpeartion.BUILD_FILE,null);
		string file_name = opened_files.nth_data(panel.get_current_page());
		int index = file_name.last_index_of("/");
		string directory = file_name.substring(0,index);

		FileOpeartion build_status;
		Dialog build_dialog;
		Label build_message;
		int exe = Posix.system("cd " + directory + " && make");

		if (exe == 0) {
			build_message = new Label("Make: Build successful!");
			build_status = FileOpeartion.BUILD_DONE;
		} else {
			build_message = new Label("Make: An error has occurred!");
			build_status = FileOpeartion.BUILD_FAIL;
		}

		build_message.show();		
		build_dialog = new Dialog.with_buttons("Build system",this,
			DialogFlags.MODAL,"OK",ResponseType.ACCEPT,null);
		var content = build_dialog.get_content_area() as Box;
		content.pack_start(build_message,true,true,10);
		build_dialog.border_width = 10;

		build_dialog.run();
		build_dialog.destroy();
		status.refresh_statusbar(build_status,null);
	}

	private void re_open_cb() {
		if (closed_files.length == 0) return;

		string last_file_path = closed_files.data[closed_files.length - 1];
		string last_file_basename = 
			File.new_for_path(last_file_path).get_basename();
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

				string f_name = opened_files.nth_data(page_n);
				opened_files.remove(opened_files.nth_data(page_n));
				panel.remove_page(page_n);

				status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);
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

		string f_name = opened_files.nth_data(panel.get_current_page());
		status.refresh_statusbar(FileOpeartion.OPEN_FILE,f_name);
		status.refresh_language(f_name);
	}

	private void search_mode_cb() {
		search_bar.search_mode_enabled = !search_bar.search_mode_enabled;
	}

	private void close_tab_cb() {
		int page = panel.get_current_page();
		if ((panel.get_n_pages() > 0) && confirm_close(page)) {
			string f_name = opened_files.nth_data(panel.get_current_page());
			status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);

			if (opened_files.nth_data(page) != untitled)
				closed_files.append_val(opened_files.nth_data(page));
			
			opened_files.remove(opened_files.nth_data(page));
			panel.remove_page(page);
			status.refresh_language(
				opened_files.nth_data(panel.get_current_page()));
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

	private bool changes_done(Gdk.EventKey event) {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		// stdout.printf("%s\n",event.str);
		
		// if (event.str == "{")
		// 	view.buffer.insert_at_cursor("}",1);
		// else if (event.str == "(")
		// 	view.buffer.insert_at_cursor(")",1);
		// else if (event.str == "[")
		// 	view.buffer.insert_at_cursor("]",1);
		// else if (event.str == "<")
		// 	view.buffer.insert_at_cursor(">",1);
		// else if (event.str == "¿")
		// 	view.buffer.insert_at_cursor("?",1);
		// else if (event.str == "¡")
		// 	view.buffer.insert_at_cursor("!",1);
		// else if (event.str == "'")
		// 	view.buffer.insert_at_cursor("'",1);
		// else if (event.str == "\"")
		// 	view.buffer.insert_at_cursor("\"",1);

		if (view.buffer.get_modified()) {
			var tab_label = panel.get_tab_label(page) as SimpleTab;

			if (!headerbar.title.contains("*"))
				headerbar.title = "*" + headerbar.title;
			if (!tab_label.tab_title.contains("*"))
				tab_label.tab_title = "*" + tab_label.tab_title;
			
			status.refresh_statusbar(FileOpeartion.EDIT_FILE,null);

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
				if (opened_files.nth_data(page) != untitled)
					closed_files.append_val(opened_files.nth_data(page));

				string f_name = opened_files.nth_data(page);
				opened_files.remove(opened_files.nth_data(page));
				panel.remove_page(page);

				status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);
				check_pages();
			}
		});

		panel.append_page(tab_widget,tab_label);
		panel.set_current_page(panel.get_n_pages() - 1);

		var view = (tab_widget as ScrolledWindow).get_child() as SourceView;
		view.key_release_event.connect(changes_done);

		panel.set_show_tabs(panel.get_n_pages() != 1);
		panel.set_tab_reorderable(tab_widget,true);
		headerbar.set_title(untitled);

		status.refresh_statusbar(FileOpeartion.NEW_FILE,null);
		status.refresh_language(untitled);
	}

	private void save_file(SourceView view,string filename) {
		try {
			FileUtils.set_contents(filename,view.buffer.text);
			view.buffer.set_modified(false);

			status.refresh_statusbar(FileOpeartion.SAVE_FILE,filename);
			status.refresh_language(filename);
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	private void next_tab_cb() {
		if (panel.get_n_pages() <= 1) return;
		int page = (panel.get_current_page() + 1) % panel.get_n_pages();
		panel.set_current_page(page);
	}

	private void prev_tab_cb() {
		if (panel.get_n_pages() <= 1) return;
		int page = (panel.get_current_page() + (panel.get_n_pages() - 1)) 
			% panel.get_n_pages();
		panel.set_current_page(page);
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

	private void quit_cb() {
		while (panel.get_n_pages() != 0)
			close_tab_cb();
		this.destroy();
	}
}