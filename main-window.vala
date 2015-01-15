using Gtk;

public class MainWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private MenuButton menu_b;
	private SourceView text_view;

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

		var action_about = new SimpleAction("about_window",null);
		action_about.activate.connect(about_window_cb);
		add_action(action_about);

		var action_lines = new SimpleAction("toggle_lines",null);
		action_lines.activate.connect(toggle_lines_cb);
		add_action(action_lines);		

		var action_quit = new SimpleAction("quit_window",null);
		action_quit.activate.connect(quit_window_cb);
		add_action(action_quit);

		try {
			builder.add_from_file("main-window.ui");
		} catch(Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		text_view = builder.get_object("text_view") as SourceView;
		text_view.override_font(Pango.FontDescription.from_string("monospace 10"));

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

	private void toggle_lines_cb() {
		text_view.show_line_numbers = !text_view.show_line_numbers;
	}

	private void quit_window_cb() {
		this.destroy();
	}
}