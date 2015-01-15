using Gtk;

public class MainWindow : ApplicationWindow {
	private string[]? filename = null;
	private HeaderBar headerbar;
	private MenuButton menu_b;
	private Notebook panel;

	public MainWindow(Gtk.Application app) {
		Object(application: app);

		window_position = WindowPosition.CENTER;
		set_default_size(700,500);
		border_width = 0;

		create_widgets();
	}

	private void create_widgets() {
		Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);

		var builder = new Builder();
		try {
			builder.add_from_file("menu.ui");
		} catch(Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		var menu_img = new Image.from_icon_name("emblem-system-symbolic",IconSize.BUTTON);
		menu_b = new MenuButton();
		menu_b.set_tooltip_text("Opciones");
		menu_b.add(menu_img);
		
		menu_b.menu_model = builder.get_object("window-menu") as MenuModel;
		menu_b.relief = Gtk.ReliefStyle.NONE;
		menu_b.use_popover = false;
		menu_b.show_all();

		var abrir = new Button.with_label("Open");
		abrir.clicked.connect(add_new_tab_from_file);
		abrir.show();

		var guardar = new Button.with_label("Save");
		guardar.clicked.connect(save_tab_to_file);
		guardar.show();

		var nuevo = new Button.from_icon_name("tab-new-symbolic",IconSize.MENU);
		nuevo.clicked.connect(new_tab_cb);
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

		var action_close_tab = new SimpleAction("close_tab",null);
		action_close_tab.activate.connect(close_tab_cb);
		add_action(action_close_tab);

		var action_lines = new SimpleAction("toggle_lines",null);
		action_lines.activate.connect(toggle_lines_cb);
		add_action(action_lines);

		var action_quit = new SimpleAction("quit_window",null);
		action_quit.activate.connect(quit_window_cb);
		add_action(action_quit);

		panel = new Notebook();
		panel.set_show_tabs(false);
		panel.scrollable = true;
		add_new_tab();
		panel.show();

		var accels = new AccelGroup();
		this.add_accel_group(accels);
		abrir.add_accelerator("activate",accels,Gdk.Key.O,Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(panel,true,true,0);
		vbox.show();

		add(vbox);
	}

	private void about_window_cb() {
		string[] authors = { "Ian Hernández <ianyo27@gmail.com>" };

        string[] documenters = { "Ian Hernández" };

        Gtk.show_about_dialog(this,
			"program-name", ("Simple Text"),
			"title","About Simple Text",
			"copyright", ("\xc2\xa9 2015 Ian Hernández"),
			"comments",("A very simple text editor."),
			"license-type", Gtk.License.GPL_2_0,
			"logo-icon-name", "text-editor",
			"documenters", documenters,
			"authors", authors,
			"version", 0.6
		);
	}

	private void new_tab_cb() {
		add_new_tab();
		panel.next_page();
	}

	private void close_tab_cb() {
		panel.remove_page(panel.get_current_page());
		panel.set_show_tabs(panel.get_n_pages()!=1);

		if(filename != null)
			stdout.printf("Archivo sin guardar.");
	}

	private void add_new_tab() {
		var builder = new Builder();

		try {
			builder.add_from_file("main-window.ui");
		} catch(Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		var text_view = builder.get_object("text_view") as SourceView;
		text_view.override_font(Pango.FontDescription.from_string("monospace 11"));

		// var manager = SourceStyleSchemeManager.get_default();
		// var def_scheme = manager.get_scheme("monokai-extended");
		// if(def_scheme == null)
		// 	def_scheme = manager.get_scheme("classic");

		// if(def_scheme != null) {
		// 	var buffer = new SourceBuffer(null);
		// 	buffer.set_style_scheme(def_scheme);
		// 	text_view = new SourceView.with_buffer(buffer);
		// 	text_view.override_font(Pango.FontDescription.from_string("monospace 11"));
		// } else {
		// 	stdout.printf("Warning!");
		// }

		var scroll = builder.get_object("scroll") as ScrolledWindow;
		scroll.show();
		
		var close = new Button.from_icon_name("gtk-close",IconSize.MENU);
		close.clicked.connect(close_tab_cb);

		var box = new Box(Orientation.HORIZONTAL,20);
		box.pack_start(new Label("Untitled"),true,true,0);
		box.pack_start(close,true,true,0);
		box.show_all();

		panel.append_page(scroll,box);
		panel.set_show_tabs(panel.get_n_pages()!=1);
		panel.set_tab_reorderable(scroll,true);
		headerbar.set_title("Untitled");
	}

	private void add_new_tab_from_file() {
		var file_chooser = new FileChooserDialog("Open File", this,
			FileChooserAction.OPEN,
			"Cancel", ResponseType.CANCEL,
			"Open", ResponseType.ACCEPT
		);

        if(file_chooser.run() == ResponseType.ACCEPT) {
	        add_new_tab();
			panel.next_page();

			var page = panel.get_nth_page(panel.get_current_page()) as ScrolledWindow;
			var view = page.get_child() as SourceView;

			var close = new Button.from_icon_name("gtk-close",IconSize.MENU);
			close.clicked.connect(close_tab_cb);

			var box = new Box(Orientation.HORIZONTAL,20);
			box.pack_start(new Label(file_chooser.get_file().get_basename()),true,true,0);
			box.pack_start(close,true,true,0);
			box.show_all();

			panel.set_tab_label(page,box);
			headerbar.set_title(file_chooser.get_filename());
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
		var page = panel.get_nth_page(panel.get_current_page()) as ScrolledWindow;
		var view = page.get_child() as SourceView;

		if((headerbar.title == "Untitled") && (view.buffer.text != "")) {
			var file_chooser = new FileChooserDialog("Save File", this,
				FileChooserAction.SAVE,
				"Cancel", ResponseType.CANCEL,
				"Save", ResponseType.ACCEPT
			);

	        if(file_chooser.run() == ResponseType.ACCEPT) {
				var close = new Button.from_icon_name("gtk-close",IconSize.MENU);
				close.clicked.connect(close_tab_cb);

				var box = new Box(Orientation.HORIZONTAL,20);
				box.pack_start(new Label(file_chooser.get_file().get_basename()),true,true,0);
				box.pack_start(close,true,true,0);
				box.show_all();

	            panel.set_tab_label(page,box);
	            headerbar.set_title(file_chooser.get_filename());
	            save_file(view,file_chooser.get_filename());
	        }
	        
	        file_chooser.destroy();
	    } else {
	    	save_file(view,headerbar.title);
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
		var page = panel.get_nth_page(panel.get_current_page()) as ScrolledWindow;
		var view = page.get_child() as SourceView;
		view.show_line_numbers = !view.show_line_numbers;
	}

	private void quit_window_cb() {
		this.destroy();
	}
}
