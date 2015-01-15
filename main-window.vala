using Gtk;

public class MainWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private MenuButton menu_b;

	public MainWindow(Gtk.Application app) {
		Object(application: app);

		window_position = WindowPosition.CENTER;
		set_default_size(700,500);
		set_title("Sin título");
		border_width = 0;

		create_widgets();
	}

	private void create_widgets() {
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

		headerbar = new HeaderBar();
		headerbar.set_title("Sin título");
		headerbar.set_show_close_button(true);
		headerbar.pack_end(menu_b);
		headerbar.show();

		set_titlebar(headerbar);

		// var accels = new AccelGroup();
		// this.add_accel_group(accels);

		var action_about = new SimpleAction("about_window",null);
		action_about.activate.connect(about_window_cb);
		add_action(action_about);

		var action_quit = new SimpleAction("quit_window",null);
		action_quit.activate.connect(quit_window_cb);
		add_action(action_quit);

		try {
			builder.add_from_file("main-window.ui");
		} catch(Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		var content = builder.get_object("content") as Box;
		content.show();
		add(content);
	}

	private void mode_changed_cb() {
		
	}

	private void get_back() {
		
	}

	private void about_window_cb() {
		string[] authors = {
			"Ian Hernández <ianyo27@gmail.com>",
			null
        };

        string[] documenters = {
			"Ian Hernández",
			null
        };

        Gtk.show_about_dialog(this,
			"program-name",
			"Simple Text",
			"title","About Simple Text",
			"version", 0.1,
			"copyright",
			"\xc2\xa9 2015 Simple Text authors",
			"license-type", Gtk.License.GPL_2_0,
			"comments",
			"A very simple text editor.",
			"authors", authors,
			"documenters", documenters,
			"logo-icon-name", "text-editor"
		);
	}

	private void quit_window_cb() {
		this.destroy();
	}
}