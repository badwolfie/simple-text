using Gtk;

public class SimpleLanguagePicker : Popover {
	public signal void language_selected(string language);

	private ProgrammingLanguages plangs;
	private ScrolledWindow scroll;
	private Box lang_box;

	private SearchEntry search_entry;
	private EntryCompletion completion;
	
	private ListStore list_store;
	private TreeIter iter;

	public SimpleLanguagePicker(Widget parent) {
		Object(relative_to: parent);
		lang_box = new Box(Orientation.VERTICAL,0);
		border_width = 3;
		add(lang_box);

		create_widgets();
	}

	private void create_widgets() {
		plangs = new ProgrammingLanguages();

		search_entry = new SearchEntry();
		search_entry.placeholder_text = "Choose your language";
		search_entry.set_width_chars(35);
		search_entry.show();
		
		completion = new EntryCompletion();
		search_entry.set_completion(completion);

		list_store = new ListStore(1,typeof(string));
		completion.set_model(list_store);
		completion.set_text_column(0);

		plangs.languages.foreach((entry) => {
			list_store.append(out iter);
			list_store.set(iter,0,entry);
		});

		var vbox = new Box(Orientation.VERTICAL,0);

		scroll = new ScrolledWindow(null,null);
		scroll.set_policy(PolicyType.NEVER,PolicyType.AUTOMATIC);
		scroll.height_request = 300;
		scroll.add(vbox);

		lang_box.pack_start(search_entry,true,true,0);
		lang_box.pack_start(scroll,true,true,0);

		plangs.languages.foreach((entry) => {
			var separator = new Separator(Orientation.HORIZONTAL);
			var label = new Label(entry);
			var evt_box = new EventBox();

			evt_box.child = label;
			evt_box.set_above_child(true);
			evt_box.button_press_event.connect((evt) => {
				language_selected(label.label);
				this.hide();
				
				return true;
			});

			vbox.pack_start(separator,true,true,0);
			vbox.pack_start(evt_box,true,true,7);
		});

		search_entry.activate.connect(() => {
			language_selected(search_entry.text);
			search_entry.text = "";
			this.hide();
		});
	}
}