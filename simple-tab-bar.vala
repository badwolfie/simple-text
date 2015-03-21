using Gtk;

public class SimpleTabBar : Box {
	private Stack stack;

	private List<SimpleTab> _tabs;
	public List<SimpleTab> tabs {
		get { return _tabs; }
	}

	public SimpleTabBar() {
		Object();
		_tabs = new List<SimpleTab>();
		orientation = Orientation.HORIZONTAL;
		spacing = 0;
		show_all();
	}

	public void set_stack(Stack stack) {
		this.stack = stack;
	}

	public void add_tab(SimpleTab tab) {
		pack_start(tab,true,true,5);
		tabs.append(tab);
		tab.tab_clicked.connect(switch_page);
	}

	public void remove_tab(SimpleTab tab) {
		tabs.remove(tab);
	}

	private void switch_page(SimpleTab tab) {
		stack.set_visible_child(tab.tab_widget);
	}
}