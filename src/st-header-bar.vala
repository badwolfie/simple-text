using Gtk;

public class StHeaderBar : HeaderBar {
	private StMainWindow parent_window;
	private MenuButton menu_b;
	
	private Button abrir;
	private Button guardar;
	private Button nuevo;
	private Button leave_fs;

	public StHeaderBar(StMainWindow parent) {
		Object();
		parent_window = parent;
		set_show_close_button(true);
		create_widgets();
		connect_signals();
	}

	private void create_widgets() {
		var builder = new Builder();
		try {
			builder.add_from_resource(
				"/com/github/badwolfie/simple-text/menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}

		menu_b = new MenuButton();
		menu_b.set_direction(ArrowType.NONE);
		
		var context_menu_b = menu_b.get_style_context();
		context_menu_b.add_class("image-button");
		
		menu_b.menu_model = builder.get_object("window-menu") as MenuModel;
		menu_b.relief = Gtk.ReliefStyle.NONE;
		menu_b.popover.width_request = 275;
		menu_b.use_popover = true;
		menu_b.show_all();

		abrir = new Button.with_label(_("Open"));
		abrir.set_tooltip_text(_("Open file") + " (Ctrl+O)");
		abrir.show();

		guardar = new Button.with_label(_("Save"));
		guardar.set_tooltip_text(_("Save file") + " (Ctrl+S)");
		guardar.show();

		nuevo = new Button.from_icon_name("tab-new-symbolic",IconSize.MENU);
		nuevo.set_tooltip_text(_("New file") + " (Ctrl+N)");
		nuevo.show();
		
		var context_nuevo = nuevo.get_style_context();
		context_nuevo.add_class("image-button");

		leave_fs = new Button.from_icon_name("view-restore-symbolic", 
												 IconSize.MENU);
		leave_fs.set_tooltip_text(_("Leave fullscreen mode"));
		pack_end(leave_fs);

		pack_start(abrir);
		pack_start(nuevo);
		pack_end(menu_b);
		pack_end(guardar);
	}

	private void connect_signals() {
		abrir.clicked.connect(parent_window.open_file_cb);
		guardar.clicked.connect(parent_window.save_tab_to_file);
		nuevo.clicked.connect(parent_window.new_tab_cb);
		leave_fs.clicked.connect(parent_window.on_fullscreen);

		var accels = new AccelGroup();
		parent_window.add_accel_group(accels);
		abrir.add_accelerator("activate",accels,Gdk.Key.O,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		guardar.add_accelerator("activate",accels,Gdk.Key.S,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		nuevo.add_accelerator("activate",accels,Gdk.Key.N,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		menu_b.add_accelerator("activate",accels,Gdk.Key.F10,
			Gdk.ModifierType.META_MASK,AccelFlags.VISIBLE);
	}
	
	public void toggle_fullscreen() {
		if ((parent_window.get_window ().get_state () & 
				Gdk.WindowState.FULLSCREEN) != 0) {
			show_close_button = true;
			leave_fs.hide();
		} else {
			show_close_button = false;
			leave_fs.show_all();
		}	
	}
}

