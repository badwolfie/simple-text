using Gtk;

public class StPreferencesDialog : Dialog {
	public StTextEditor editor { private get; construct; }

	private StackSwitcher switcher;
	private Stack stack;
	
	private CheckButton line_numbers_check;
	private CheckButton right_margin_check;
	private SpinButton right_margin_spin;
	
	private CheckButton current_line_check;
	private CheckButton brackets_check;
	private CheckButton save_workspace_check;
	
	private ComboBox tab_width_combo;
	private CheckButton insert_spaces_check;
	private CheckButton auto_indent_check;
	private CheckButton grid_pattern_check;
	
	private CheckButton default_typo_check;
	private FontButton font_button;
	private StSourceStylePicker scheme_chooser;
	private CheckButton prefer_dark_check;

	public StPreferencesDialog(StMainWindow parent, StTextEditor ed) {
		Object(use_header_bar: (int) true, editor: ed);
		set_transient_for(parent);
		border_width = 10;
	}
	
	construct {
		var box_view = new ListBox();
		box_view.selection_mode = SelectionMode.NONE;
		
		var box_editor = new ListBox();
		box_editor.selection_mode = SelectionMode.NONE;
		
		var box_typo = new ListBox();
		box_typo.selection_mode = SelectionMode.NONE;
	
		stack = new Stack();
		stack.set_transition_type(StackTransitionType.SLIDE_LEFT_RIGHT);
		stack.set_transition_duration(300);
		
		switcher = new StackSwitcher();
		switcher.set_stack(stack);
		
		var header_bar = get_header_bar() as HeaderBar;
		header_bar.custom_title = switcher;
		
		get_content_area().pack_start(stack,true,true,0);
		get_content_area().spacing = 10;
		
		stack.add_titled(box_view,"view",_("View"));
		stack.add_titled(box_editor,"editor",_("Editor"));
		stack.add_titled(box_typo,"typo",_("Typography and colors"));
		
		line_numbers_check = new CheckButton.with_label(
			_("Show line numbers"));
		line_numbers_check.toggled.connect(() => {
			editor.show_line_numbers = line_numbers_check.active;
		});
				
		right_margin_check = new CheckButton.with_label(
			_("Show right margin on column:"));
		right_margin_check.toggled.connect(() => {
			right_margin_spin.sensitive = right_margin_check.active;
			editor.show_right_margin = right_margin_check.active;
		});
			
		right_margin_spin = new SpinButton.with_range(80,120,20);
		right_margin_spin.sensitive = right_margin_check.active;
		right_margin_spin.value_changed.connect(() => {
			editor.right_margin_at = right_margin_spin.get_value_as_int();
		});
		
		var hbox_margin = new Box(Orientation.HORIZONTAL,0);
		hbox_margin.pack_start(right_margin_check,true,true,0);
		hbox_margin.pack_start(right_margin_spin,true,true,0);
		
		var aux_label_1 = new Label("");
		aux_label_1.halign = Align.START;
		
		var highlight_label = new Label("<b>" + _("Highlighting") + "</b>");
		highlight_label.use_markup = true;
		highlight_label.halign = Align.START;
		
		current_line_check = new CheckButton.with_label(
			_("Highlight current line"));
		current_line_check.toggled.connect(() => {
			editor.highlight_current_line = current_line_check.active;
		});

		brackets_check = new CheckButton.with_label(
			_("Highlight matching brackets"));
		brackets_check.toggled.connect(() => {
			editor.highlight_brackets = brackets_check.active;
		});

		grid_pattern_check = new CheckButton.with_label(
			_("Show grid pattern"));
		grid_pattern_check.toggled.connect(() => {
			editor.show_grid_pattern = grid_pattern_check.active;
		});
		
		box_view.add(line_numbers_check);
		box_view.add(hbox_margin);
		box_view.add(grid_pattern_check);
		
		box_view.add(aux_label_1);
		box_view.add(highlight_label);
		box_view.add(current_line_check);
		box_view.add(brackets_check);
		
		
		var indent_label = new Label("<b>" + _("Indentation") + "</b>");
		indent_label.use_markup = true;
		indent_label.halign = Align.START;
		
		var tab_width_label = new Label(_("Tab width:"));
		tab_width_label.halign = Align.START;
		tab_width_combo = new ComboBox();
		tab_width_label.mnemonic_widget = tab_width_combo;
		
		TreeIter iter;
		var model = new Gtk.ListStore(1,typeof(int));
		tab_width_combo.model = model;
		
		model.append(out iter);
		model.set(iter,0,2,-1);
		model.append(out iter);
		model.set(iter,0,3,-1);
		model.append(out iter);
		model.set(iter,0,4,-1);
		model.append(out iter);
		model.set(iter,0,8,-1);
		
		var renderer = new Gtk.CellRendererText ();
		tab_width_combo.pack_start(renderer,true);
		tab_width_combo.add_attribute(renderer,"text",0);
		tab_width_combo.changed.connect(on_tab_width_changed);
		
		var hbox_tab_width = new Box(Orientation.HORIZONTAL,0);
		hbox_tab_width.pack_start(tab_width_label,true,true,0);
		hbox_tab_width.pack_start(tab_width_combo,true,true,0);
		
		insert_spaces_check = new CheckButton.with_label(
			_("Indent using spaces"));
		insert_spaces_check.toggled.connect(() => {
			editor.insert_spaces = insert_spaces_check.active;
		});
		
		var aux_label_2 = new Label("");
		aux_label_2.halign = Align.START;
		
		auto_indent_check = new CheckButton.with_label(
			_("Activate auto indent"));
		auto_indent_check.toggled.connect(() => {
			editor.auto_indent = auto_indent_check.active;
		});
		
		var workspace_label = new Label("<b>" + _("Workspace") + "</b>");
		workspace_label.use_markup = true;
		workspace_label.halign = Align.START;
		
		save_workspace_check = new CheckButton.with_label(
			_("Save current workspace on closing"));
		save_workspace_check.toggled.connect(() => {
			editor.save_workspace = save_workspace_check.active;
		});
		
		/* string workspace_path = Environment.get_home_dir() + 
			"/.simple-text/saved-workspace";
		var saved_workspace = File.new_for_path(workspace_path);
		if (!saved_workspace.query_exists())
			Posix.system("rm -f " + workspace_path); */
		
		box_editor.add(indent_label);
		box_editor.add(hbox_tab_width);
		box_editor.add(insert_spaces_check);
		box_editor.add(auto_indent_check);
		
		box_editor.add(aux_label_2);
		box_editor.add(workspace_label);
		box_editor.add(save_workspace_check);

		
		var typo_label = new Label("<b>" + _("Typography") + "</b>");
		typo_label.use_markup = true;
		typo_label.halign = Align.START;
		
		default_typo_check = new CheckButton.with_label(
			_("Use default typography") + " (Monospace 10)");
		
		default_typo_check.toggled.connect(() => {
			font_button.sensitive = !default_typo_check.active;
			editor.use_default_typo = default_typo_check.active;
		});
			
		font_button = new FontButton();
		font_button.sensitive = !default_typo_check.active;
		font_button.use_font = true;
		
		font_button.font_set.connect (() => {
			editor.editor_font = font_button.font_name;
		});
			
		var aux_label_3 = new Label("");
		aux_label_3.halign = Align.START;
		
		var color_scheme_label = new Label("<b>" + _("Color Scheme") + "</b>");
		color_scheme_label.use_markup = true;
		color_scheme_label.halign = Align.START;

		scheme_chooser = new StSourceStylePicker();
		scheme_chooser.style_selected.connect(on_scheme_selected);
		scheme_chooser.height_request = 100;

		var frame = new Frame(null);
		frame.add(scheme_chooser);

		prefer_dark_check = new CheckButton.with_label(
			_("Use dark theme variant"));
		prefer_dark_check.toggled.connect(() => {
			editor.prefer_dark = prefer_dark_check.active;
		});
			
		box_typo.add(typo_label);
		box_typo.add(default_typo_check);
		box_typo.add(font_button);
		box_typo.add(aux_label_3);
		box_typo.add(color_scheme_label);
		box_typo.add(frame);
		box_typo.add(prefer_dark_check);
		
		show_all();
		
		line_numbers_check.active = editor.show_line_numbers;
		editor.notify["show-line-numbers"].connect((pspec) => {
			line_numbers_check.active = editor.show_line_numbers;
		});
		
		right_margin_check.active = editor.show_right_margin;
		editor.notify["show-right-margin"].connect((pspec) => {
			right_margin_check.active = editor.show_right_margin;
		});
		
		right_margin_spin.value = (double) editor.right_margin_at;
		editor.notify["right-margin-at"].connect((pspec) => {
			right_margin_spin.value = (double) editor.right_margin_at;
		});
		
		current_line_check.active = editor.highlight_current_line;
		editor.notify["highlight-current-line"].connect((pspec) => {
			current_line_check.active = editor.highlight_current_line;
		});
		
		brackets_check.active = editor.highlight_brackets;
		editor.notify["highlight-brackets"].connect((pspec) => {
			brackets_check.active = editor.highlight_brackets;
		});
		
		set_combo_box_from_int(tab_width_combo,editor.tab_width);		
		editor.notify["tab-width"].connect((pspec) => {
			set_combo_box_from_int(tab_width_combo,editor.tab_width);
		});
		
		insert_spaces_check.active = editor.insert_spaces;
		editor.notify["insert-spaces"].connect((pspec) => {
			insert_spaces_check.active = editor.insert_spaces;
		});
		
		auto_indent_check.active = editor.auto_indent;
		editor.notify["auto-indent"].connect((pspec) => {
			auto_indent_check.active = editor.auto_indent;
		});
		
		save_workspace_check.active = editor.save_workspace;
		editor.notify["save-workspace"].connect((pspec) => {
			save_workspace_check.active = editor.save_workspace;
		});

		grid_pattern_check.active = editor.show_grid_pattern;
		editor.notify["show-grid-pattern"].connect((pspec) => {
			grid_pattern_check.active = editor.show_grid_pattern;
		});
		
		default_typo_check.active = editor.use_default_typo;
		editor.notify["use-default-typo"].connect((pspec) => {
			default_typo_check.active = editor.use_default_typo;
		});
		
		font_button.font_name = editor.editor_font;
		editor.notify["editor-font"].connect((pspec) => {
			font_button.font_name = editor.editor_font;
		});

		prefer_dark_check.active = editor.prefer_dark;
		editor.notify["prefer-dark"].connect((pspec) => {
			prefer_dark_check.active = editor.prefer_dark;
		});
	}

	private void on_scheme_selected(string scheme) {
		editor.color_scheme = scheme;
	}
	
	private void set_combo_box_from_int (Gtk.ComboBox combo, int value) {
		TreeIter iter;
		var valid = combo.model.get_iter_first(out iter);

		while (valid) {
			int v;

			combo.model.get(iter, 0, out v, -1);
			if (v == value) break;
            valid = combo.model.iter_next(ref iter);
		}

		if (!valid)
			valid = combo.model.get_iter_first (out iter);

		combo.set_active_iter (iter);
    }
    
    private void on_tab_width_changed(ComboBox combo) {
		TreeIter iter;
		combo.get_active_iter(out iter);
		
		int value;
		combo.model.get(iter, 0, out value, -1);
		editor.tab_width = value;
    }

	
	protected override void response(int id) {
        hide();
    }

    protected override bool delete_event(Gdk.EventAny event) {
        hide();
        return true;
    }
}
