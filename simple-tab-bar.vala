using Gtk;

public class SimpleTabBar : Box {
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

	public void add_tab(SimpleTab tab) {
		pack_end(tab,true,true,0);
		tabs.append(tab);
	}

	public void remove_tab(SimpleTab tab) {
		tabs.remove(tab);
	}
}