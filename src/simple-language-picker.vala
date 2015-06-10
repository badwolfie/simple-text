using Gtk;

public class SimpleLanguagePicker : Popover {
	public signal void language_selected(string language);

	private ProgrammingLanguages plangs;
	private ScrolledWindow scroll;
	private Box lang_box;
	private Frame frame;

	private SearchEntry search_entry;
	private ListBox list_view;

	public SimpleLanguagePicker(Widget parent) {
		Object(relative_to:parent);
		border_width = 5;

		create_widgets();
	}

	private void create_widgets() {
		plangs = new ProgrammingLanguages();
		
		list_view = new ListBox();
		list_view.selection_mode = SelectionMode.SINGLE;
		list_view.activate_on_single_click = true;
		
		list_view.row_activated.connect(on_language_selected);
		list_view.set_filter_func(row_filter);

		search_entry = new SearchEntry();
		search_entry.placeholder_text = _("Search highlight mode...");
		search_entry.set_width_chars(30);
		search_entry.key_release_event.connect((event) => {
			list_view.invalidate_filter();
			return true;
		});
	
		var lang_manager = SourceLanguageManager.get_default();
		foreach (string lang_id in lang_manager.language_ids) {
			var lang = lang_manager.get_language(lang_id);
			var label = new Label(lang.name);
			list_view.add(label);
		}
		
		scroll = new ScrolledWindow(null,null);
		scroll.set_policy(PolicyType.NEVER,PolicyType.AUTOMATIC);
		scroll.height_request = 300;
		scroll.add(list_view);
		
		lang_box = new Box(Orientation.VERTICAL,0);
		lang_box.pack_start(search_entry,true,true,0);
		lang_box.pack_start(scroll,true,true,0);
		
		frame = new Frame(null);
		frame.add(lang_box);
		add(frame);
	}
	
	private void on_language_selected(ListBoxRow row) {
		Label lang = row.get_child() as Label;
		language_selected(lang.label);
		search_entry.text = "";
		this.hide();
	}
	
	private bool row_filter(ListBoxRow row) {
		var label = row.get_child() as Label;
		return label.label.down().contains(search_entry.text.down());
	}
}
