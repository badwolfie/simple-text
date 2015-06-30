using Gtk;

public enum FileOpeartion {
	NULL_OPERATION,
	NEW_FILE,
	OPEN_FILE,
	EDIT_FILE,
	SAVE_FILE,
	CLOSE_FILE,
	BUILD_FILE,
	BUILD_DONE,
	BUILD_FAIL
}

public class StStatusbar : Box {
	public signal void change_syntax_request(string language);

	private StLanguagePicker lang_picker;
	private StMainWindow parent_window;
	private EventBox evt_box;
	private Label _label;
	public Label label {
		get { return _label; }
	}

	private Statusbar status;
	private uint context_id;

	public StStatusbar(StMainWindow parent) {
		Object();
		parent_window = parent;
		create_widgets();
	}

	private void create_widgets() {
		this.orientation = Orientation.HORIZONTAL;
		this.spacing = 0;

		status = new Statusbar();
		context_id = status.get_context_id("status");
		status.show();

		_label = new Label("");
		_label.show();

		evt_box = new EventBox();
		evt_box.child = _label;
		evt_box.set_above_child(true);
		evt_box.button_press_event.connect(on_label_pressed);
		evt_box.show();

		lang_picker = new StLanguagePicker(_label);
		lang_picker.language_selected.connect(change_syntax);

		this.pack_start(status,false,true,0);
		this.pack_end(evt_box,false,true,15);
	}

	public void toggle_picker() {
		if (lang_picker.get_visible())
			lang_picker.hide();
		else 
			lang_picker.show_all();
	}

	public void refresh_statusbar(FileOpeartion operation, string? filename) {
		status.pop(context_id);

		string build_string = "Building...";
		switch (operation) {
			case FileOpeartion.NULL_OPERATION:
				status.push(context_id,"");
				break;
			case FileOpeartion.NEW_FILE:
				status.push(context_id,_("New file"));
				break;
			case FileOpeartion.OPEN_FILE:
				status.push(context_id,_("Opened") + ": " + filename);
				break;
			case FileOpeartion.EDIT_FILE:
				status.push(context_id,_("Editing..."));
				break;
			case FileOpeartion.SAVE_FILE:
				status.push(context_id,_("Saved") + ": " + filename);
				break;
			case FileOpeartion.CLOSE_FILE:
				status.push(context_id,_("Closed") + ": " + filename);
				break;
			case FileOpeartion.BUILD_FILE:
				status.push(context_id,_(build_string));
				break;
			case FileOpeartion.BUILD_DONE:
				status.push(context_id,_(build_string) + " " + _("Done"));
				break;
			case FileOpeartion.BUILD_FAIL:
				status.push(context_id,_(build_string) + " " + _("Failed"));
				break;
		}
	}

	public void refresh_language(string? lang_name) {
		if (lang_name == null)
			_label.label = "Plain text";
		else {
			_label.label = lang_name;
		}
	}

	private bool on_label_pressed(Gdk.EventButton evt) {
		if (lang_picker.get_visible())
			lang_picker.hide();
		else 
			lang_picker.show_all();
		return true;
	}

	private void change_syntax(string language) {
		_label.label = language;
		change_syntax_request(language);
	}
}
