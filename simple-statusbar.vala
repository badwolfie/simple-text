using Gtk;

public enum FileOpeartion {
	NEW_FILE,
	OPEN_FILE,
	EDIT_FILE,
	SAVE_FILE,
	CLOSE_FILE,
	BUILD_FILE,
	BUILD_DONE,
	BUILD_FAIL
}

public class SimpleStatusbar : Box {
	private MainWindow parent_window;
	private Label _label;
	public Label label {
		get { return _label; }
	}

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

		_label = new Label("");
		_label.show();

		this.pack_start(status,false,true,0);
		this.pack_end(_label,false,true,15);
	}

	public void refresh_statusbar(FileOpeartion operation, string? file_name) {
		status.pop(context_id);

		switch (operation) {
			case FileOpeartion.NEW_FILE:
				status.push(
					context_id,
					"New file");
				break;
			case FileOpeartion.OPEN_FILE:
				status.push(
					context_id,
					"Opened " + file_name);
				break;
			case FileOpeartion.EDIT_FILE:
				status.push(
					context_id,
					"Editing...");
				break;
			case FileOpeartion.SAVE_FILE:
				status.push(
					context_id,
					"Saved " + file_name);
				break;
			case FileOpeartion.CLOSE_FILE:
				status.push(
					context_id,
					"Closed " + file_name);
				break;
			case FileOpeartion.BUILD_FILE:
				status.push(
					context_id,
					"Building...");
				break;
			case FileOpeartion.BUILD_DONE:
				status.push(
					context_id,
					"Building... Done");
				break;
			case FileOpeartion.BUILD_FAIL:
				status.push(
					context_id,
					"Building... Failed");
				break;
		}
	}

	public void refresh_language(string? file_name) {
		if (file_name == null)
			_label.label = "";
		else {
			var plangs = new ProgrammingLanguages();
			string p_name = plangs.get_lang_name(file_name);
			_label.label = p_name == null? "Plain text":	p_name;
		}
	}
}