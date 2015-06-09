using Gtk;

public class SimpleSourceStylePicker : ScrolledWindow {
	public signal void style_selected(string style_scheme);
	
	private const string header = "#include <gtksourceview/gtksource.h>";
	private ListBox list_view;
	
	public SimpleSourceStylePicker() {
		Object(hadjustment: null, vadjustment :null);
		set_policy(PolicyType.NEVER,PolicyType.AUTOMATIC);
		create_widgets();
	}
	
	private void create_widgets() {
		list_view = new ListBox();
		list_view.selection_mode = SelectionMode.SINGLE;
		list_view.row_activated.connect(on_style_selected);
		list_view.activate_on_single_click = true;
		
		var scheme_manager = SourceStyleSchemeManager.get_default();
		foreach (string scheme in scheme_manager.scheme_ids) {
			var lang = SourceLanguageManager.get_default().get_language("c");
			var buff = new SourceBuffer.with_language(lang);
			var source_scheme = scheme_manager.get_scheme(scheme);
			
			buff.highlight_syntax = true;
			buff.style_scheme = source_scheme;
			buff.text = "/* %s */\n%s".printf(source_scheme.name, header);
			buff.highlight_matching_brackets = false;
			
			var view = new SourceView.with_buffer(buff);
			view.right_margin_position = 30;
			view.show_right_margin = true;
			view.show_line_numbers = true;
			view.can_focus = false;
			view.editable = false;
			
			list_view.add(view);
		}
		
		add(list_view);
	}
	
	private void on_style_selected(ListBoxRow row) {
		var view = row.get_child() as SourceView;
		var buff = view.buffer as SourceBuffer;
		style_selected(buff.style_scheme.id);
	}
}
