using Gtk;

public class SimpleHeaderBar : HeaderBar {
	private MainWindow parent_window;
	private MenuButton menu_b;
	
	private Button abrir;
	private Button guardar;
	private Button nuevo;
	private Button build;

	private bool _buildable;
	public bool buildable {
		get { return _buildable; }
		set {
			if (build != null) {
				_buildable = value;
				build.sensitive = buildable;
			}
		}
	}

	public SimpleHeaderBar(MainWindow parent) {
		Object();
		parent_window = parent;
		set_show_close_button(true);
		create_widgets();
		connect_signals();
	}

	private void create_widgets() {
		var builder = new Builder();
		try {
			builder.add_from_file("resources/menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		menu_b = new MenuButton();
		menu_b.set_direction(ArrowType.NONE);
		
		menu_b.menu_model = builder.get_object("window-menu") as MenuModel;
		menu_b.relief = Gtk.ReliefStyle.NONE;
		menu_b.use_popover = true;
		menu_b.show_all();

		abrir = new Button.with_label("Open");
		abrir.set_tooltip_text("Open file (Ctrl+O)");
		abrir.show();

		guardar = new Button.with_label("Save");
		guardar.set_tooltip_text("Save file (Ctrl+S)");
		guardar.show();

		nuevo = new Button.from_icon_name("tab-new-symbolic",IconSize.MENU);
		nuevo.set_tooltip_text("New file (Ctrl+N)");
		nuevo.show();

		build = new Button.from_icon_name("media-playback-start-symbolic",
			IconSize.MENU);
		build.set_tooltip_text("Build using make (Ctrl+B)");
		buildable = false;
		build.show();

		pack_start(abrir);
		pack_start(nuevo);
		pack_end(menu_b);
		pack_end(build);
		pack_end(guardar);
	}

	private void connect_signals() {
		abrir.clicked.connect(parent_window.add_new_tab_from_file);
		guardar.clicked.connect(parent_window.save_tab_to_file);
		nuevo.clicked.connect(parent_window.new_tab_cb);
		build.clicked.connect(parent_window.build_code);

		var accels = new AccelGroup();
		parent_window.add_accel_group(accels);
		abrir.add_accelerator("activate",accels,Gdk.Key.O,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		guardar.add_accelerator("activate",accels,Gdk.Key.S,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		nuevo.add_accelerator("activate",accels,Gdk.Key.N,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		build.add_accelerator("activate",accels,Gdk.Key.B,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
	}
}
