using Gtk;
using Vte;

/**
 * The application main window.
 */
public class StMainWindow : ApplicationWindow {
	/** Variable that stores the application preferences */
	private StTextEditor _editor;
	public StTextEditor editor { get { return _editor; } }

	/** Constant string to create the title of untitled files */
	private string untitled = _("Untitled file");
	
	/** List that stores the recently closed files so they can be reopened */
	private Array<string> closed_files;
	
	/** List that stores the files that are currently open */
	private List<string> opened_files;
	
	/** Auxiliar counter for numering opened files */
	private int counter = 0;

	/** Custom headerbar for the window */
	private StHeaderBar headerbar;
	
	/** Custom headerbar for the window when it's on fullscreen mode */
	private StHeaderBar fs_headerbar;
	
	/** Custom statusbar for the window */
	private StStatusbar status;
	
	/** Embeded terminal for the window */
	private Terminal terminal;
	
	/** Custom tab bar for the window */
	private StTabBar tab_bar;
	
	/** Stack that stores and shows the opened files */
	private Stack documents;

	/** SearchEntry for the window (dummy only, for now...) */
	private SearchEntry search_entry;
	
	/** SearchBar for showing the SearchEntry and buttons to interact with it */
	private SearchBar search_bar;
	
	/** Button that interacts with the SearchEntry finds previous occurrency*/
	private Button previous_search;
	
	/** Button that interacts with the SearchEntry finds next occurrency*/
	private Button next_search;
	
	/** Array of files to be opened from the command line option */
	private File[] _arg_files = null;
	public File[] arg_files {
		set {
			_arg_files = value;
			
			if ((_editor != null) && _editor.save_workspace)
				load_workspace();

			if (_arg_files != null) {
				foreach (var file in _arg_files) {
					var file_location = File.new_for_path(file.get_path());
					
					if (file_location.query_exists())
						add_new_tab_from_file(file.get_path());
				} 
			}
		}
	}

	/**
	 * Function that loads the saved workspace (if any) and opens all files 
	 * listed in it.
	 *
	 * @return void
	 */
	private void load_workspace() {
		string workspace = null;

		try {
			FileUtils.get_contents(
				Environment.get_home_dir() + "/.simple-text/saved-workspace", 
				out workspace);
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}

		if (workspace != null) {
			if (workspace == "")
				new_tab_cb();
			else {
				var workspace_files = workspace.split("\n");
				foreach (string file in workspace_files) {
					if ((file != "") && File.new_for_path(file).query_exists())
						add_new_tab_from_file(file);
				}

				if (opened_files.length() == 0)
					new_tab_cb();
			}
		}
	}

	/**
	 * Function that saves the currently open files into the workspace so it 
	 * can be loaded on opening.
	 *
	 * @return void
	 */
	private void save_workspace() {
		string workspace = "";
		opened_files.foreach((entry) => {
			if (entry.contains("/"))
				workspace += (entry + "\n");
		});

		try {
			FileUtils.set_contents(
				Environment.get_home_dir() + "/.simple-text/saved-workspace", 
				workspace);
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	/**
	 * Class constructor
	 *
	 * @param app Gtk.Application for this
	 * @param editor StTextEditor that stores the application preferences
	 */
	public StMainWindow(Gtk.Application app, StTextEditor editor) {
		Object(application: app);
		_editor = editor;
		_editor.notify["prefer-dark"].connect((pspec) => {
			Gtk.Settings.get_default().set(
				"gtk-application-prefer-dark-theme",_editor.prefer_dark);
		});

		opened_files = new List<string>();
		closed_files = new Array<string>();

		window_position = WindowPosition.CENTER;
		set_default_size(1000,700);
		border_width = 0;
		maximize();
		
		create_widgets();
		this.destroy.connect(quit_cb);
	}

	/**
	 * Function that creates and initializes all widgets in the window.
	 * 
	 * @return void
	 */
	private void create_widgets() {
		Gtk.Settings.get_default().set(
			"gtk-application-prefer-dark-theme", _editor.prefer_dark);

		fs_headerbar = new StHeaderBar(this);
		headerbar = new StHeaderBar(this);
		set_titlebar(headerbar);
		headerbar.show();

		var action_re_open = new SimpleAction("re_open", null);
		action_re_open.activate.connect(re_open_cb);
		add_action(action_re_open);

		var action_save_as = new SimpleAction("save_as", null);
		action_save_as.activate.connect(save_as_cb);
		add_action(action_save_as);

		var action_next_tab = new SimpleAction("next_tab", null);
		action_next_tab.activate.connect(next_tab_cb);
		add_action(action_next_tab);

		var action_prev_tab = new SimpleAction("prev_tab", null);
		action_prev_tab.activate.connect(prev_tab_cb);
		add_action(action_prev_tab);

		var action_close_tab = new SimpleAction("close_tab", null);
		action_close_tab.activate.connect(close_tab_cb);
		add_action(action_close_tab);
		
		var action_close_all = new SimpleAction("close_all", null);
		action_close_all.activate.connect(on_close_all);
		add_action(action_close_all);

		var action_set_syntax = new SimpleAction("set_syntax", null);
		action_set_syntax.activate.connect(set_syntax_cb);
		add_action(action_set_syntax);
		
		var action_show_terminal = new SimpleAction("toggle_terminal", null);
		action_show_terminal.activate.connect(on_show_terminal);
		add_action(action_show_terminal);

		var action_search_mode = new SimpleAction("search_mode", null);
		action_search_mode.activate.connect(search_mode_cb);
		add_action(action_search_mode);

		var action_reload = new SimpleAction("reload", null);
		action_reload.activate.connect(on_reload);
		add_action(action_reload);

		var action_fullscreen = new SimpleAction("fullscreen", null);
		action_fullscreen.activate.connect(on_fullscreen);
		add_action(action_fullscreen);

		var action_build = new SimpleAction("build", null);
		action_build.activate.connect(build_code);
		add_action(action_build);

		search_entry = new SearchEntry();
		search_entry.placeholder_text = _("Enter your search...");
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

		tab_bar = new StTabBar();
		tab_bar.set_stack(documents);
		tab_bar.page_switched.connect(on_page_switched);
		tab_bar.page_closed.connect(on_page_close);
		tab_bar.show();

		status = new StStatusbar(this);
		status.change_syntax_request.connect(change_syntax_cb);
		status.show();

		var separator = new Separator(Orientation.HORIZONTAL);
		separator.show();

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(fs_headerbar,false,true,0);
		vbox.pack_start(search_bar,false,true,0);
		vbox.pack_start(tab_bar,false,true,7);
		vbox.pack_start(separator,false,true,0);
		vbox.pack_start(documents,true,true,0);
		vbox.pack_start(status,false,true,0);
		vbox.height_request = 400;
		vbox.show();

		terminal = new Terminal();
		var pane = new Paned(Orientation.VERTICAL);
		pane.pack1(vbox,false,false);
		pane.pack2(terminal,true,true);
		pane.show();
		
		
		if ((_editor != null) && !_editor.save_workspace)
			new_tab_cb();

		add(pane);
	}

	/**
	 * Function that toggles fullscreen mode for the application.
	 *
	 * @return void
	 */
	public void on_fullscreen() {
		fs_headerbar.toggle_fullscreen();
		if ((this.get_window ().get_state () & Gdk.WindowState.FULLSCREEN) != 0) {
			this.unfullscreen ();
			fs_headerbar.hide();
		}
		else {
			this.fullscreen ();
			fs_headerbar.show_all();
		}
	}

	/**
	 * Function that forces the file buffer to reload in case of an external
	 * modification.
	 *
	 * @return void
	 */
	private void on_reload() {}

	/**
	 * Function that gets executed when a page is switched on the Stack, and a 
	 * signal is sent from it.
	 *
	 * @param tab StTab that is now being shown
	 * @return void
	 */
	private void on_page_switched(StTab tab) {
		int page_num = tab_bar.get_page_num(tab);
		headerbar.title = opened_files.nth_data(page_num);
		fs_headerbar.title = opened_files.nth_data(page_num);
		
		if (terminal.get_visible()) {
			terminal.reset(true,true);
			terminal.hide();
			
			var visible_doc = documents.visible_child as ScrolledWindow;
			visible_doc.get_child().grab_focus();
		}
		
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		var lang_name = current_doc.text_view.get_language_name();
		status.refresh_statusbar(FileOpeartion.NULL_OPERATION,null);
		status.refresh_language(lang_name);
	}

	/**
	 * Function that gets called when a request for changing the current view's 
	 * language is made.
	 *
	 * @param language string containing the requested language
	 * @return void
	 */
	private void change_syntax_cb(string language) {
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		var p_langs = new StProgrammingLanguages();

		string lang_id = p_langs.get_lang_id(language);
		current_doc.text_view.change_language(lang_id);
	}
	
	/**
	 * Function called when a request for making the embeded terminal visible is
	 * made.
	 *
	 * @return void
	 */
	private void on_show_terminal() {
		if (terminal.get_visible()) {
			terminal.reset(true,true);
			terminal.hide();
			
			var visible_doc = documents.visible_child as ScrolledWindow;
			visible_doc.get_child().grab_focus();
		} else {
			var current_doc = 
				tab_bar.get_current_doc(documents.visible_child);
			
			int page_num = tab_bar.get_page_num(current_doc);
			string filename = opened_files.nth_data(page_num);
			
			string working_dir;
			if (filename.contains(untitled))
				working_dir = Environment.get_home_dir();
			else {
				working_dir = Path.get_dirname(filename);
			}
			
			terminal.cursor_blink_mode = CursorBlinkMode.ON;
			terminal.cursor_shape = CursorShape.BLOCK;
			terminal.input_enabled = true;
			terminal.allow_bold = true;

			/* Gdk.RGBA background = Gdk.RGBA();
			background.parse("#2d2d2d");
		
			Gdk.RGBA foreground = Gdk.RGBA();
			foreground.parse("#ffffff");
			terminal.set_colors(foreground,background,null); */
		
			try {
				terminal.spawn_sync(
					PtyFlags.DEFAULT, 
					working_dir, 
					{ Vte.get_user_shell() }, 
					null,
					SpawnFlags.DO_NOT_REAP_CHILD,
					null,
					null,
					null);
			} catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
			
			terminal.show();
			terminal.grab_focus();
		}
	}

	/**
	 * Function that toggles the sytax setter popover
	 *
	 * @return void
	 */
	private void set_syntax_cb() {
		status.toggle_picker();
	}
	
	/**
	 * Function called when a request for opening a file is made
	 * 
	 * @return void
	 */
	public void open_file_cb() {
		var file_chooser = new FileChooserDialog(_("Open File"), this,
			FileChooserAction.OPEN,
			_("Cancel"), ResponseType.CANCEL,
			_("Open"), ResponseType.ACCEPT
		);

		if (documents.visible_child != null) {
			var current_doc = 
				tab_bar.get_current_doc(documents.visible_child);
			string filename =
				opened_files.nth_data(tab_bar.get_page_num(current_doc));

			if (filename.contains(untitled))
				file_chooser.set_current_folder(Environment.get_home_dir());
			else
				file_chooser.set_current_folder(Path.get_dirname(filename));
		}
		
		file_chooser.select_multiple = true;
		if (file_chooser.run() == ResponseType.ACCEPT) {
			var filenames = file_chooser.get_filenames();
			filenames.foreach((entry) => {
				add_new_tab_from_file((string) entry);
			});
			
		}
		
		file_chooser.destroy();
	}

	/**
	 * Function that adds a new tab from a file
	 *
	 * @param filename string that contains the name of the file to be opened
	 * @return void
	 */
	private void add_new_tab_from_file(string filename) {
		if (file_is_opened(filename)) {
			check_pages();
			return;
		}
		
		var tab_label = new StTab.from_file(editor,
			Path.get_basename(filename),
			filename);
			
		tab_label.view_drag_n_drop.connect(add_new_tab_from_file);
		add_new_tab(tab_label);
		
		var current_doc = tab_bar.get_current_doc(
			documents.visible_child);
		int page_num = tab_bar.get_page_num(current_doc);

		headerbar.set_title(filename);
		fs_headerbar.set_title(filename);
		opened_files.insert(filename, page_num);
		
		var lang_name = current_doc.text_view.get_language_name();
		status.refresh_statusbar(FileOpeartion.OPEN_FILE, filename);
		status.refresh_language(lang_name);

		check_pages();
	}
	
	/**
	 * Function that determins wheter or not a file is already open 
	 *
	 * @param needle string that contains the name of the file to be checked
	 * @return bool
	 */
	private bool file_is_opened(string needle) {
		for (int i = 0; i < opened_files.length(); i++) {
			if (needle == opened_files.nth_data(i)) return true;
		}
		
		return false;
	}

	/**
	 * Function that saves the content of a tab document to a file
	 *
	 * @return void
	 */
	public void save_tab_to_file() {
		var current_tab = documents.visible_child as ScrolledWindow;
		if (current_tab == null) return ;

		var view = current_tab.get_child() as SourceView;
		var current_doc = tab_bar.get_current_doc(current_tab);
		int page_num = tab_bar.get_page_num(current_doc);

		if (headerbar.title.contains(untitled)) {
			if (view.buffer.text == "") return;
			var file_chooser = new FileChooserDialog(_("Save File"), this,
				FileChooserAction.SAVE,
				_("Cancel"), ResponseType.CANCEL,
				_("Save"), ResponseType.ACCEPT
			);

			file_chooser.set_current_folder(Environment.get_home_dir());
			string filename =
				opened_files.nth_data(tab_bar.get_page_num(current_doc));
			file_chooser.set_current_name(Path.get_basename(filename));

			switch (file_chooser.run()) {
				default:
					break;
				case ResponseType.ACCEPT:
					current_doc.tab_title = 
						file_chooser.get_file().get_basename();
					headerbar.set_title(file_chooser.get_filename());
					fs_headerbar.set_title(file_chooser.get_filename());
					save_file(view,file_chooser.get_filename());
					current_doc.mark_title();
					
					opened_files.remove(opened_files.nth_data(page_num));
					opened_files.insert(file_chooser.get_filename(),page_num);

					var lang_name = current_doc.text_view.get_language_name();
					status.refresh_language(lang_name);
					reset_changes(current_doc);
					break;
			}
			file_chooser.destroy();
		} else if (current_doc.tab_title.contains("*")) {
			string filename = opened_files.nth_data(page_num);
			save_file(view, filename);
			reset_changes(current_doc);
		}
	}
	
	/**
	 * Function called when a "save as" request is made
	 *
	 * @return void
	 */
	private void save_as_cb() {
		if (documents.visible_child == null) return ;

		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		string filename = 
			opened_files.nth_data(tab_bar.get_page_num(current_doc));
		int page_num = tab_bar.get_page_num(current_doc);
		var view = current_doc.text_view as SourceView;

		if ((filename.contains(untitled)) && (view.buffer.text == "")) return;

		var file_chooser = new FileChooserDialog(_("Save File"), this,
			FileChooserAction.SAVE,
			_("Cancel"), ResponseType.CANCEL,
			_("Save"), ResponseType.ACCEPT
		);

		file_chooser.set_current_name(Path.get_basename(filename));
		if (filename.contains(untitled))
			file_chooser.set_current_folder(Environment.get_home_dir());
		else 
			file_chooser.set_current_folder(Path.get_dirname(filename));

		switch (file_chooser.run()) {
			case ResponseType.ACCEPT:
				current_doc.tab_title = file_chooser.get_file().get_basename();
				headerbar.set_title(file_chooser.get_filename());
				fs_headerbar.set_title(file_chooser.get_filename());
				save_file(view,file_chooser.get_filename());
				current_doc.mark_title();

				opened_files.remove(opened_files.nth_data(page_num));
				opened_files.insert(file_chooser.get_filename(),page_num);

				var lang_name = current_doc.text_view.get_language_name();
				status.refresh_language(lang_name);
				reset_changes(current_doc);
				break;
			default:
				break;
		}

		file_chooser.destroy();
	}

	/**
	 * Function called when a "new tab" request is made
	 *
	 * @return void
	 */
	public void new_tab_cb() {
		opened_files.append("%s %d".printf(untitled,counter + 1));
		var tab = new StTab(editor);
		tab.view_drag_n_drop.connect(add_new_tab_from_file);
		add_new_tab(tab);
	
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		var lang_name = current_doc.text_view.get_language_name();
		
		status.refresh_statusbar(FileOpeartion.NEW_FILE,null);
		status.refresh_language(lang_name);
	}

	/**
	 * Function that runs "make" on the file's directory in attempt to build the
	 * code (if its a language that needs to be compiled
	 *
	 * You need to have a previously created Makefile on said directory in order
	 * for this to work
	 *
	 * @return void
	 */
	public void build_code() {
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		int page_num = tab_bar.get_page_num(current_doc);
		
		string filename = opened_files.nth_data(page_num);
		string directory = Path.get_dirname(filename);
		
		save_tab_to_file();
		
		var plangs = new StProgrammingLanguages();
		if (!plangs.is_buildable(current_doc.text_view.get_language_name())) 
			return;
		
		status.refresh_statusbar(FileOpeartion.BUILD_FILE,null);

		FileOpeartion build_status;
		Dialog build_dialog;
		Label build_message;
		int exe = Posix.system("cd \"" + directory + "\" && make");

		if (exe == 0) {
			build_message = new Label("Make: " + _("Build successful!"));
			build_status = FileOpeartion.BUILD_DONE;
		} else {
			build_message = new Label("Make: " + _("An error has occurred!"));
			build_status = FileOpeartion.BUILD_FAIL;
		}

		build_message.show();		
		build_dialog = new Dialog.with_buttons(_("Build system"),this,
			DialogFlags.MODAL,_("Accept"),ResponseType.ACCEPT,null);
		var content = build_dialog.get_content_area() as Box;
		content.pack_start(build_message,true,true,10);
		build_dialog.border_width = 10;

		build_dialog.run();
		build_dialog.destroy();
		status.refresh_statusbar(build_status,null);
	}
	
	/**
	 * Function called when a "re open file" request is made
	 *
	 * @return void 
	 */
	private void re_open_cb() {
		if (closed_files.length == 0) return;

		string last_file_path = closed_files.data[closed_files.length - 1];
		string last_file_basename = 
			File.new_for_path(last_file_path).get_basename();
		closed_files.remove_index(closed_files.length - 1);

		var tab_label = new StTab.from_file(editor,
			last_file_basename,
			last_file_path);
		tab_label.view_drag_n_drop.connect(add_new_tab_from_file);
		add_new_tab(tab_label);
		
		var current_doc = tab_bar.get_current_doc(
			documents.visible_child);
		int page_num = tab_bar.get_page_num(current_doc);

		headerbar.set_title(last_file_basename);
		fs_headerbar.set_title(last_file_basename);
		opened_files.insert(last_file_path, page_num);

		string f_name = opened_files.nth_data(page_num);
		var lang_name = current_doc.text_view.get_language_name();
		status.refresh_statusbar(FileOpeartion.OPEN_FILE,f_name);
		status.refresh_language(lang_name);

		current_doc = tab_bar.get_current_doc(documents.visible_child);
		check_pages();
	}

	/**
	 * Dummy function
	 *
	 * @return void
	 */
	private void search_mode_cb() {
		search_bar.search_mode_enabled = !search_bar.search_mode_enabled;
	}

	/**
	 * Function called when a "close tab" request is made
	 * 
	 * @return void
	 */
	private void close_tab_cb() {
		var current_doc =
			tab_bar.get_current_doc(documents.visible_child);
			
		if (confirm_close(current_doc))
			tab_bar.close_page(current_doc);
	}
	
	/**
	 * Function called when a tab gets closed
	 *
	 * @param tab StTab that has been closed
	 * @param page_num int that contains the page number of the closed tab
	 * @return void
	 */
	private void on_page_close(StTab? tab, int page_num) {
		string f_name = opened_files.nth_data(page_num);
		status.refresh_statusbar(FileOpeartion.CLOSE_FILE,f_name);

		if (!f_name.contains(untitled))
			closed_files.append_val(f_name);
		opened_files.remove(opened_files.nth_data(page_num));
		
		tab_bar.switch_page_next(tab, false);
		tab.tab_widget.destroy();
		
		tab.destroy();
		check_pages();

		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		tab_bar.switch_page(current_doc, false);
		current_doc.mark_title();
		
		var lang_name = current_doc.text_view.get_language_name();
		status.refresh_language(lang_name);
	}
	
	/**
	 * Dummy function
	 *
	 * @return void
	 */
	private void search_stuff_next() {
		stdout.printf("Next\n");
	}
	
	/**
	 * Dummy function
	 *
	 * @return void
	 */
	private void search_stuff_prev() {
		stdout.printf("Previous\n");
	}

	/**
	 * Function that checks the number of tabs currently opened, if there are 
	 * two or more opened the tab bar gets shown, otherwise gets hidden
	 *
	 * Also, if no tabs are opened the title is changed to "St Text"
	 *
	 * @return void
	 */
	private void check_pages() {
		if (opened_files.length() < 2) {
			tab_bar.hide();
			
			if (opened_files.length() == 0) {
				headerbar.title = "St Text";
				fs_headerbar.title = "St Text";
			}
		} else {
			tab_bar.show();
		}
	}
	
	/**
	 * Function that checks wheter or not a change has been made to the 
	 * currently opened document 
	 * 
	 * If so, an '*' character is prepended to the tab label
	 * 
	 * @param event Gdk.EventKey that triggered this function
	 * @return bool
	 */
	private bool changes_done(Gdk.EventKey event) {
		var page = documents.visible_child as ScrolledWindow;
		var view = page.get_child() as SourceView;
		
		if (view.buffer.get_modified()) {
			var current_doc = tab_bar.get_current_doc(page);

			if (!current_doc.tab_title.contains("*")){
				current_doc.tab_title = "*" + current_doc.tab_title;
				current_doc.mark_title();
			}

			status.refresh_statusbar(FileOpeartion.EDIT_FILE,null);
			return false;
		}
		
		return true;
	}

	/**
	 * Function that removes the '*' character from the tab label after the 
	 * document is saved
	 *
	 * @param tab_label StTab which's label will be restore
	 * @return void 
	 */
	private void reset_changes(StTab tab_label) {
		if (tab_label.tab_title.contains("*")) {
			tab_label.tab_title = tab_label.tab_title.replace("*","");
			tab_label.mark_title();
		}
	}
	
	/**
	 * Function that adds a new tab to the Stack
	 *
	 * @param tab_label StTab added to the Stack
	 * @return void
	 */
	private void add_new_tab(StTab tab_label) {
		var tab_title = "tab - %d".printf(counter++);
		documents.add_titled(
			tab_label.tab_widget,tab_title,tab_label.tab_title);
		tab_bar.add_page(tab_label,true);

		var view = 
			(tab_label.tab_widget as ScrolledWindow).get_child() as SourceView;
		view.key_release_event.connect(changes_done);
		
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		int page_num = tab_bar.get_page_num(current_doc);
		string filename = opened_files.nth_data(page_num);
		
		headerbar.set_title(filename);
		fs_headerbar.set_title(filename);		
		check_pages();
	}
	
	/**
	 * Function that saves the content of a document to a file
	 * 
	 * @param view SourceView which's content will be saved
	 * @param filename string that contains the path for the file where the 
	 * view's content will be saved
	 * @return void
	 */
	private void save_file(SourceView view, string filename) {
		try {
			FileUtils.set_contents(filename,view.buffer.text);
			view.buffer.set_modified(false);
			
			var current_doc = 
				tab_bar.get_current_doc(documents.visible_child);
			var lang_name = current_doc.text_view.get_language_name();
			
			status.refresh_statusbar(FileOpeartion.SAVE_FILE,filename);
			status.refresh_language(lang_name); 
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	/**
	 * Function called when a request is made to change from the current tab to 
	 * the next one
	 *
	 * @return void
	 */
	private void next_tab_cb() {
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		tab_bar.switch_page_next(current_doc, false);
	}

	/**
	 * Function called when a request is made to change from the current tab to 
	 * the previous one
	 *
	 * @return void
	 */
	private void prev_tab_cb() {
		var current_doc = tab_bar.get_current_doc(documents.visible_child);
		tab_bar.switch_page_prev(current_doc, false);
	}	

	/**
	 * Function called when a "close tab" request was made, checks wheter or not
	 * there's unsaved changes, shows a ConfirmExit dialog and returns the 
	 * user's choice to save them before closing or not
	 *
	 * @param tab StTab that is being checked
	 * @return bool 
	 */
	private bool confirm_close(StTab? tab) {
		if (tab == null) return false;
		if (tab.tab_title.contains("*")) {
			tab_bar.switch_page(tab, true);

			var confirmar = new MessageDialog(this,
				DialogFlags.MODAL, 
				MessageType.QUESTION, 
				ButtonsType.NONE, 
				_("Confirm operation")
			);
			
			confirmar.secondary_text = 
				_("Do you wish to save changes before closing?");

			confirmar.add_button(_("Close without saving"),ResponseType.ACCEPT);		
			confirmar.add_button(_("Cancel"),ResponseType.CANCEL);
			confirmar.add_button(_("Save"),ResponseType.APPLY);

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

	/**
	 * Function called when a "close all" request is made, it checks and closes 
	 * every opened document before closing its tab
	 *
	 * @return void
	 */
	private void on_close_all() {
		while (opened_files.length() != 0) 
			close_tab_cb();
	}

	/**
	 * Function called when a "quit" request is made, it checks and closes every
	 * opened document before closing the window
	 *
	 * @return void
	 */
	private void quit_cb() {
		if ((_editor != null) && _editor.save_workspace)
			save_workspace();
		on_close_all();
		this.destroy();
	}
}
