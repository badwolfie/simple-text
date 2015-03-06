using Gtk;

public enum OPERATION {
	NEW_FILE,
	OPEN_FILE,
	EDIT_FILE,
	SAVE_FILE,
	CLOSE_FILE
}

public class SimpleStatusbar : Box {
	private MainWindow parent_window;
	private Label label;

	private Statusbar status;
	private uint context_id;

	public SimpleStatusbar(MainWindow parent) {
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

		label = new Label("");
		label.show();

		this.pack_start(status,false,true,0);
		this.pack_end(label,false,true,15);
	}

	public void refresh_statusbar(OPERATION operation, string? file_name) {
		status.pop(context_id);

		switch (operation) {
			case OPERATION.NEW_FILE:
				status.push(
					context_id,
					"New file");
				break;
			case OPERATION.OPEN_FILE:
				status.push(
					context_id,
					"Opened " + file_name);
				break;
			case OPERATION.EDIT_FILE:
				status.push(
					context_id,
					"Editing...");
				break;
			case OPERATION.SAVE_FILE:
				status.push(
					context_id,
					"Saved " + file_name);
				break;
			case OPERATION.CLOSE_FILE:
				status.push(
					context_id,
					"Closed " + file_name);
				break;
		}
	}

	public void refresh_language(string? file_name) {
		if (file_name == null)
			label.label = "";
		else {
			var plangs = new ProgrammingLanguages();
			string p_name = plangs.get_lang_name(file_name);
			label.label = p_name == null? "Plain text":	p_name;
		}
	}
}