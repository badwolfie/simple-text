using Gtk;

public class MainWindow : ApplicationWindow {
	private string untitled = "Untitled";
	private Array<string> closed_files;
	private List<string> opened_files;
	private int counter = 0;

	private SimpleHeaderBar headerbar;
	private SimpleStatusbar status;
	
	private SimpleTabBar tab_bar;
	private Stack documents;

	private SearchEntry search_entry;
	private SearchBar search_bar;
	private Button previous_search;
	private Button next_search;

	public MainWindow(Gtk.Application app) {
		Object(application: app);
		opened_files = new List<string>();
		closed_files = new Array<string>();

		window_position = WindowPosition.CENTER_ALWAYS;
		set_default_size(1000,700);
		border_width = 0;
		maximize();

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

		var action_set_syntax = new SimpleAction("set_syntax",null);
		action_set_syntax.activate.connect(set_syntax_cb);
		add_action(action_set_syntax);

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

		documents = new Stack();
		documents.set_transition_type(StackTransitionType.OVER_LEFT_RIGHT);
		documents.set_transition_duration(250);
		documents.show();

		tab_bar = new SimpleTabBar();
		tab_bar.set_stack(documents);
		tab_bar.page_switched.connect(on_page_switched);
		tab_bar.page_closed.connect(on_page_close);
		tab_bar.show();

		status = new SimpleStatusbar(this);
		status.change_syntax_request.connect(change_syntax_cb);
		status.show();

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(search_bar,false,true,0);
		vbox.pack_start(tab_bar,false,true,5);
		vbox.pack_start(documents,true,true,0);
		vbox.pack_start(status,false,true,0);
		vbox.show();

		new_tab_cb();
		add(vbox);
	}

	private void on_page_switched(SimpleTab tab) {
		int page_num = tab_bar.get_page_num(tab);
		headerbar.title = opened_files.nth_data(page_num);
		
		status.refresh_statusbar(FileOpeartion.NULL_OPERATION,null);
		status.refresh_language(headerbar.title);
	}

	private void change_syntax_cb(string language) {
		var current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();

		string lang_id = p_langs.get_lang_id_from_name(language);
		current_page.text_view.change_language(lang_id);
	}

	private void set_syntax_cb() {
		status.toggle_picker();
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
			add_new_tab(tab_label);

			var current_page = tab_bar.get_current_page(
				documents.visible_child);
			int page_num = tab_bar.get_page_num(current_page);

			headerbar.set_title(file_chooser.get_filename());
			opened_files.insert(file_chooser.get_filename(),page_num);

			string f_name = opened_files.nth_data(page_num);
			status.refresh_statusbar(FileOpeartion.OPEN_FILE,f_name);
			status.refresh_language(f_name);
		}

		file_chooser.destroy();
		check_pages();
	}

	public void save_tab_to_file() {
		var current_doc = documents.visible_child as ScrolledWindow;
		var view = current_doc.get_child() as SourceView;

		var tab_label = tab_bar.get_current_page(current_doc);
		int page_num = tab_bar.get_page_num(tab_label);

		if (headerbar.title == untitled) {
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
					tab_label.tab_title = 
						file_chooser.get_file().get_basename();
					headerbar.set_title(file_chooser.get_filename());
					save_file(view,file_chooser.get_filename());
					tab_label.mark_title();
					
					opened_files.remove(opened_files.nth_data(page_num));
					opened_files.insert(file_chooser.get_filename(),page_num);

					status.refresh_language(file_chooser.get_filename());
					reset_changes(tab_label);
					break;
			}

			file_chooser.destroy();
		} else if (headerbar.title.contains("*")) {
			string file_name = opened_files.nth_data(page_num);
			save_file(view,file_name);
			reset_changes(tab_label);
		}
	}

	private void save_as_cb() {
		var current_page = tab_bar.get_current_page(documents.visible_child);
		string filename =
			opened_files.nth_data(tab_bar.get_page_num(current_page));
		int page_num = tab_bar.get_page_num(current_page);
		var view = current_page.text_view as SourceView;

		if ((filename == untitled) && (view.buffer.text == "")) return;

		var file_chooser = new FileChooserDialog("Save File", this,
			FileChooserAction.SAVE,
			"Cancel", ResponseType.CANCEL,
			"Save", ResponseType.ACCEPT
		);

		int index = filename.last_index_of("/");
		file_chooser.set_current_name(filename.substring(index + 1));

		switch (file_chooser.run()) {
			case ResponseType.ACCEPT:
				current_page.tab_title = file_chooser.get_file().get_basename();
				headerbar.set_title(file_chooser.get_filename());
				save_file(view,file_chooser.get_filename());
				current_page.mark_title();

				opened_files.remove(opened_files.nth_data(page_num));
				opened_files.insert(file_chooser.get_filename(),page_num);

				status.refresh_language(file_chooser.get_filename());
				reset_changes(current_page);
				break;
			default:
				break;
		}

		file_chooser.destroy();
	}

	public void new_tab_cb() {
		opened_files.append(untitled);
		var tab = new SimpleTab();
		add_new_tab(tab);

		status.refresh_statusbar(FileOpeartion.NEW_FILE,null);
		status.refresh_language(untitled);
	}

	public void build_code() {
		save_tab_to_file();
		status.refresh_statusbar(FileOpeartion.BUILD_FILE,null);

		var current_page = tab_bar.get_current_page(documents.visible_child);
		int page_num = tab_bar.get_page_num(current_page);

		string file_name = opened_files.nth_data(page_num);
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
		add_new_tab(tab_label);
		
		var current_page = tab_bar.get_current_page(
			documents.visible_child);
		int page_num = tab_bar.get_page_num(current_page);

		headerbar.set_title(last_file_basename);
		opened_files.insert(last_file_basename,page_num);

		string f_name = opened_files.nth_data(page_num);
		status.refresh_statusbar(FileOpeartion.OPEN_FILE,f_name);
		status.refresh_language(f_name);

		current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();
		headerbar.buildable = p_langs.is_buildable(current_page.tab_title);
	}

	private void search_mode_cb() {
		search_bar.search_mode_enabled = !search_bar.search_mode_enabled;
	}

	private void close_tab_cb() {
		SimpleTab current_page =
			tab_bar.get_current_page(documents.visible_child);
		if (confirm_close(current_page))
			tab_bar.close_page(current_page);

		current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();
		headerbar.buildable = p_langs.is_buildable(current_page.tab_title);
	}

	private void on_page_close(SimpleTab? tab, int page_num) {
		string f_name = opened_files.nth_data(page_num);
		status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);

		if (f_name != untitled)
			closed_files.append_val(f_name);
		opened_files.remove(opened_files.nth_data(page_num));
		status.refresh_language(opened_files.nth_data(page_num));
		
		tab_bar.switch_page_next(tab);
		tab.tab_widget.destroy();
		tab.destroy();
		check_pages();

		tab_bar.get_current_page(documents.visible_child).mark_title();
	}

	private void toggle_lines_cb() {
		var page = documents.visible_child as ScrolledWindow;
		var view = page.get_child() as SourceView;
		view.show_line_numbers = !view.show_line_numbers;
	}

	private void search_stuff_next() {
		stdout.printf("Next\n");
	}

	private void search_stuff_prev() {
		stdout.printf("Previous\n");
	}

	private void check_pages() {
		if (opened_files.length() < 2) {
			tab_bar.hide();
			
			if (opened_files.length() == 0) {
				headerbar.title = "Simple Text";
			}
		} else {
			tab_bar.show();
		}
	}

	private bool changes_done(Gdk.EventKey event) {
		var page = documents.visible_child as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if (view.buffer.get_modified()) {
			var tab_label = tab_bar.get_current_page(page);

			if (!tab_label.tab_title.contains("*")){
				tab_label.tab_title = "*" + tab_label.tab_title;
				tab_label.mark_title();
			}

			status.refresh_statusbar(FileOpeartion.EDIT_FILE,null);
			return false;
		}
		
		return true;
	}

	private void reset_changes(SimpleTab tab_label) {
		if (tab_label.tab_title.contains("*")) {
			tab_label.tab_title = tab_label.tab_title.replace("*","");
			tab_label.mark_title();
		}
	}

	private void add_new_tab(SimpleTab tab_label) {
		var tab_title = "tab-%d".printf(counter++);
		documents.add_titled(
			tab_label.tab_widget,tab_title,tab_label.tab_title);
		tab_bar.add_page(tab_label,true);

		var view = 
			(tab_label.tab_widget as ScrolledWindow).get_child() as SourceView;
		view.key_release_event.connect(changes_done);
		headerbar.set_title(untitled);

		var current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();
		headerbar.buildable = p_langs.is_buildable(current_page.tab_title);
		
		check_pages();
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
		var current_page = tab_bar.get_current_page(documents.visible_child);
		tab_bar.switch_page_next(current_page);

		current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();
		headerbar.buildable = p_langs.is_buildable(current_page.tab_title);
	}

	private void prev_tab_cb() {
		var current_page = tab_bar.get_current_page(documents.visible_child);
		tab_bar.switch_page_prev(current_page);

		current_page = tab_bar.get_current_page(documents.visible_child);
		var p_langs = new ProgrammingLanguages();
		headerbar.buildable = p_langs.is_buildable(current_page.tab_title);
	}	

	private bool confirm_close(SimpleTab? tab) {
		if (tab == null) return false;
		if (tab.tab_title.contains("*")) {
			tab_bar.switch_page(tab);

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
		while (opened_files.length() != 0)
			close_tab_cb();
		this.destroy();
	}
}
