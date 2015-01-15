using Gtk;

public class MainWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private MenuButton menu_b;

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
			"version", 0.1
		);
	}

	private void quit_window_cb() {
		this.destroy();
	}
}