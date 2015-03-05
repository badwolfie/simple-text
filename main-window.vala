using Gtk;

public class MainWindow : ApplicationWindow {
	private string untitled = "Untitled";
	private List<string> filenames;
	private HeaderBar headerbar;
	private MenuButton menu_b;
	private Notebook panel;

	private SearchEntry search_entry;
	private SearchBar search_bar;
	private Button previous_search;
	private Button next_search;

	public MainWindow(Gtk.Application app) {
		Object(application: app);
		filenames = new List<string>();

		window_position = WindowPosition.CENTER;
		set_default_size(1000,700);
		border_width = 0;

		create_widgets();
	}

	private void create_widgets() {
		Gtk.Settings.get_default().set(
			"gtk-application-prefer-dark-theme",true);

		var builder = new Builder();
		try {
			builder.add_from_file("menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		menu_b = new MenuButton();
		menu_b.set_direction(ArrowType.NONE);
		menu_b.set_tooltip_text("Menu");
		
		menu_b.menu_model = builder.get_object("window-menu") as MenuModel;
		menu_b.relief = Gtk.ReliefStyle.NONE;
		menu_b.use_popover = false;
		menu_b.show_all();

		var abrir = new Button.with_label("Open");
		abrir.clicked.connect(add_new_tab_from_file);
		abrir.set_tooltip_text("Open file");
		abrir.show();

		var guardar = new Button.with_label("Save");
		guardar.clicked.connect(save_tab_to_file);
		guardar.set_tooltip_text("Save file");
		guardar.show();

		var nuevo = new Button.from_icon_name("tab-new-symbolic",IconSize.MENU);
		nuevo.clicked.connect(new_tab_cb);
		nuevo.set_tooltip_text("New tab");
		nuevo.show();

		headerbar = new HeaderBar();
		headerbar.set_show_close_button(true);
		set_titlebar(headerbar);
		headerbar.show();

		headerbar.pack_start(abrir);
		headerbar.pack_start(nuevo);
		headerbar.pack_end(menu_b);
		headerbar.pack_end(guardar);

		var action_about = new SimpleAction("about_window",null);
		action_about.activate.connect(about_window_cb);
		add_action(action_about);

		var action_tab = new SimpleAction("new_tab",null);
		action_tab.activate.connect(new_tab_cb);
		add_action(action_tab);

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

		var action_quit = new SimpleAction("quit_window",null);
		action_quit.activate.connect(quit_window_cb);
		add_action(action_quit);

		search_entry = new SearchEntry();
		search_entry.placeholder_text = "Enter your search...";
		search_entry.set_width_chars(55);

		search_entry.search_changed.connect(search_stuff_n);
		search_entry.activate.connect(search_stuff_n);
		search_entry.show();

		next_search = new Button.from_icon_name(
			"go-down-symbolic",IconSize.MENU);
		next_search.clicked.connect(search_stuff_n);
		next_search.show();

		previous_search = new Button.from_icon_name(
			"go-up-symbolic",IconSize.MENU);
		previous_search.clicked.connect(search_stuff_p);
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

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(search_bar,false,true,0);
		vbox.pack_start(panel,true,true,0);
		vbox.show();

		var accels = new AccelGroup();
		this.add_accel_group(accels);
		abrir.add_accelerator("activate",accels,Gdk.Key.O,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		guardar.add_accelerator("activate",accels,Gdk.Key.S,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);

		panel.scrollable = true;
		filenames.append(untitled);
		add_new_tab();
		
		panel.show();
		add(vbox);
	}

	private void about_window_cb() {
		string[] authors = { "Ian Hernández <ianyo27@gmail.com>" };

        string[] documenters = { "Ian Hernández" };

        Gtk.show_about_dialog(this,
			"program-name", ("Simple Text"),
			"title","About Simple Text",
			"copyright", ("\xc2\xa9 2015 Ian Hernández"),
			"comments", ("A very simple text editor."),
			"license-type", Gtk.License.GPL_2_0,
			"logo-icon-name", "text-editor",
			"documenters", documenters,
			"authors", authors,
			"version", "0.7"
		);
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
				var tab_label = new TabLabel.with_title(
				file_chooser.get_file().get_basename());
	            tab_label.tab_widget = page;
	            tab_label.close_clicked.connect((page) => {
	            	int page_n = panel.page_num(page);

	            	if (confirm_close(page_n)) {
						filenames.remove(filenames.nth_data(page_n));
						panel.remove_page(page_n);
						check_pages();
					}
				});

	            panel.set_tab_label(page,tab_label);
	            headerbar.set_title(file_chooser.get_file().get_basename());
	            save_file(view,file_chooser.get_filename());

	            filenames.remove(filenames.nth_data(panel.get_current_page()));
	            filenames.insert(file_chooser.get_filename(),
	            	panel.get_current_page());
				break;
			default:
				break;
		}
        
        file_chooser.destroy();
	}

	private void search_mode_cb() {
		search_bar.search_mode_enabled = !search_bar.search_mode_enabled;
	}

	private void new_tab_cb() {
		add_new_tab();
		filenames.append(untitled);
		panel.next_page();
	}

	private void search_stuff_n() {
		stdout.printf("Next\n");
		// TextIter.forward_search(search_entry.text,TextSearchFlags.TEXT_ONLY,null,null,null);
	}

	private void search_stuff_p() {
		stdout.printf("Previous\n");
	}

	private bool confirm_close(int page) {
		if ((panel.get_tab_label(panel.get_nth_page(page)) 
			as TabLabel).tab_title.contains("*")) {
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

	private void close_tab_cb() {
		int page = panel.get_current_page();
		if ((panel.get_n_pages() > 0) && confirm_close(page)) {
			filenames.remove(filenames.nth_data(page));
			panel.remove_page(page);
			check_pages();
		}
	}

	private void check_pages() {
		panel.set_show_tabs(panel.get_n_pages() != 1);
		
		if (panel.get_n_pages() == 0)
			headerbar.title = "Simple Text";
	}

	private void add_new_tab() {
		var tab_label = new TabLabel();
		var tab_widget = tab_label.tab_widget;

		tab_label.close_clicked.connect((tab_widget) => {
			int page = panel.page_num(tab_widget);

			if (confirm_close(page)) {
				filenames.remove(filenames.nth_data(page));
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
	}

	private bool changes_done() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if (view.buffer.get_modified()) {
			var tab_label = panel.get_tab_label(page) as TabLabel;

			if (!headerbar.title.contains("*"))
				headerbar.title = "*" + headerbar.title;
			if (!tab_label.tab_title.contains("*"))
				tab_label.tab_title = "*" + tab_label.tab_title;
			
			return false;
		}
		
		return true;
	}

	private void add_new_tab_from_file() {
		var file_chooser = new FileChooserDialog("Open File", this,
			FileChooserAction.OPEN,
			"Cancel", ResponseType.CANCEL,
			"Open", ResponseType.ACCEPT
		);

        if (file_chooser.run() == ResponseType.ACCEPT) {
	        add_new_tab();
			panel.next_page();

			var page = panel.get_nth_page(panel.get_current_page()) 
				as ScrolledWindow;
			var view = page.get_child() as SourceView;

			var tab_label = new TabLabel.with_title(
				file_chooser.get_file().get_basename());
			tab_label.tab_widget = page;
			tab_label.close_clicked.connect((page) => {
				int page_n = panel.page_num(page);

				if (confirm_close(page_n)) {
					filenames.remove(filenames.nth_data(page_n));
					panel.remove_page(page_n);
					check_pages();
				}
			});

			panel.set_tab_label(page,tab_label);
			headerbar.set_title(file_chooser.get_file().get_basename());
			open_file(view,file_chooser.get_filename());
		}

		file_chooser.destroy();
	}

	private void open_file(SourceView view,string filename) {
		try {
			string text;
			FileUtils.get_contents(filename, out text);
			view.buffer.text = text;
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	private void save_tab_to_file() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if ((filenames.nth_data(panel.get_current_page()) == untitled) 
			&& (view.buffer.text != "")) {
			var file_chooser = new FileChooserDialog("Save File", this,
				FileChooserAction.SAVE,
				"Cancel", ResponseType.CANCEL,
				"Save", ResponseType.ACCEPT
			);

			switch (file_chooser.run()) {
				case ResponseType.ACCEPT:
					var tab_label = new TabLabel.with_title(
					file_chooser.get_file().get_basename());
		            tab_label.tab_widget = page;
		            tab_label.close_clicked.connect((page) => {
		            	int page_n = panel.page_num(page);

		            	if (confirm_close(page_n)) {
							filenames.remove(filenames.nth_data(page_n));
							panel.remove_page(page_n);
							check_pages();
						}
					});

		            panel.set_tab_label(page,tab_label);
		            headerbar.set_title(file_chooser.get_file().get_basename());
		            save_file(view,file_chooser.get_filename());

		            filenames.remove(filenames.nth_data(panel.get_current_page()));
		            filenames.insert(file_chooser.get_filename(),
		            	panel.get_current_page());
		            break;
		        default:
		        	break;
			}

	        file_chooser.destroy();
		} else {
			string file_name = filenames.nth_data(panel.get_current_page());
			save_file(view,file_name);
		}
	}

	private void save_file(SourceView view,string filename) {
		try {
            FileUtils.set_contents(filename,view.buffer.text);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
	}

	private void toggle_lines_cb() {
		var page = panel.get_nth_page(panel.get_current_page()) 
			as ScrolledWindow;
		var view = page.get_child() as SourceView;
		view.show_line_numbers = !view.show_line_numbers;
	}

	private void quit_window_cb() {
		this.destroy();
	}
}
