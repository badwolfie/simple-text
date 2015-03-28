using Gtk;

public class SimpleTextEditor : Gtk.Application {
	private MainWindow ventana;

	private const GLib.ActionEntry[] app_entries = {
        { "about", about_cb, null, null, null },
        { "quit", quit_cb, null, null, null },
    };

	public SimpleTextEditor() {
		Object(application_id: "badwolfie.simple-text.app",
			flags: ApplicationFlags.NON_UNIQUE);
	}

	protected override void startup() {
		base.startup();

		add_action_entries(app_entries,this);
		ventana = new MainWindow(this);

		var builder = new Gtk.Builder();
		try {
			builder.add_from_file("menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}
		
		var menu = builder.get_object("appmenu") as MenuModel;
		set_app_menu(menu);

		const string[] accels_re_open = {"<control><shift>T",null};
		set_accels_for_action("win.re_open",accels_re_open);

		const string[] accels_save_as = {"<control><shift>S",null};
		set_accels_for_action("win.save_as",accels_save_as);

		const string[] accels_next_tab = {"<control>Tab",null};
		set_accels_for_action("win.next_tab",accels_next_tab);

		const string[] accels_prev_tab = {"<control><shift>Tab",null};
		set_accels_for_action("win.prev_tab",accels_prev_tab);

		const string[] accels_close = {"<control>W",null};
		set_accels_for_action("win.close_tab",accels_close);

		const string[] accels_search = {"<control>F",null};
		set_accels_for_action("win.search_mode",accels_search);

		const string[] accels_lines = {"<control>L",null};
		set_accels_for_action("win.toggle_lines",accels_lines);

		const string[] accels_quit = {"<control>Q",null};
		set_accels_for_action("win.quit_window",accels_quit);
	}

	protected override void activate() {
		base.activate();
		ventana.present();
	}

	protected override void shutdown() {
		base.shutdown();
	}

	private void about_cb() {
		string[] authors = { "Ian Hernández <ianyo27@gmail.com>" };

        string[] documenters = { "Ian Hernández" };

        Gtk.show_about_dialog(ventana,
			"program-name", ("Simple Text"),
			"title","About Simple Text",
			"copyright", ("\xc2\xa9 2015 Ian Hernández"),
			"comments",("A very simple text editor written in Vala."),
			"license-type", Gtk.License.GPL_2_0,
			"logo-icon-name", "text-editor",
			"documenters", documenters,
			"authors", authors,
			"version", "0.9"
		);
	}

	private void quit_cb() {
		ventana.destroy();
	}

	public static int main(string[] args) {
		Gtk.Window.set_default_icon_name ("text-editor");
		var app = new SimpleTextEditor();
		return app.run(args);
	}
}