using Gtk;

public class SimpleTabBar : Box {
	public signal void page_closed(SimpleTab tab, int page_num);

	private int tab_extra_num = 0;
	public int tab_num = 0;
	private Stack stack;

	private Box extra_box;
	private Button extra_menu;
	private Popover extra_popup;

	private List<SimpleTab> _extra_tabs;
	public List<SimpleTab> extra_tabs {
		get { return _extra_tabs; }
	}

	private List<SimpleTab> _tabs;
	public List<SimpleTab> tabs {
		get { return _tabs; }
	}

	public SimpleTabBar() {
		Object();
		orientation = Orientation.HORIZONTAL;
		spacing = 0;
		create_widgets();
	}

	private void create_widgets() {
		_tabs = new List<SimpleTab>();
		_extra_tabs = new List<SimpleTab>();
		
		extra_box = new Box(Orientation.VERTICAL,0);
		extra_menu = new Button.from_icon_name(
			"view-more-symbolic",IconSize.MENU);
		extra_menu.clicked.connect(() => {
			if (extra_popup.get_visible())
				extra_popup.hide();
			else
				extra_popup.show_all();
		});

		extra_popup = new Popover(extra_menu);
		pack_end(extra_menu,false,true,3);
		extra_popup.add(extra_box);
		
		show_all();
		extra_menu.hide();
	}

	public void set_stack(Stack stack) {
		this.stack = stack;
	}

	public void add_page(SimpleTab tab, bool new_page) {
		if (tab_num < 5) {
			if (tab_extra_num == 0) extra_menu.hide();
			pack_start(tab,true,true,5);
			_tabs.append(tab);
			tab_num++;
		} else {
			extra_menu.show();
			extra_box.pack_start(tab,true,true,5);
			_extra_tabs.append(tab);
			tab_extra_num++;
		}
		
		tab.close_clicked.connect(close_page);
		tab.tab_clicked.connect(switch_page);

		if (new_page) {
			switch_page(tab);
			refresh_marked();
			tab.mark_title();
		}
	}

	private void switch_page(SimpleTab tab) {
		stack.set_visible_child(tab.tab_widget);
		refresh_marked();
		tab.mark_title();
	}

	public SimpleTab get_current_page(Widget current_doc) {
		SimpleTab? current_tab = null;
		for (int i = 0; i < _tabs.length(); i++) {
			if (_tabs.nth_data(i).tab_widget == current_doc)
				current_tab = _tabs.nth_data(i);
		}

		if (current_tab == null) {
			for (int i = 0; i < _extra_tabs.length(); i++) {
				if (_extra_tabs.nth_data(i).tab_widget == current_doc)
					current_tab = _extra_tabs.nth_data(i);
			}
		}

		return current_tab;
	}

	public void switch_page_next(SimpleTab current_tab) {
		if (_tabs.index(current_tab) != -1) {
			if (current_tab == _tabs.last().data) {
				if (tab_extra_num > 0)
					switch_page(_extra_tabs.first().data);
				else
					switch_page(_tabs.first().data);
			} else {
				var tab = _tabs.nth_data(_tabs.index(current_tab) + 1);
				switch_page(tab);
			}
		} else if (_extra_tabs.index(current_tab) != -1) {
			if (current_tab == _extra_tabs.last().data)
				switch_page(_tabs.first().data);
			else {
				var tab = _extra_tabs.nth_data(
					_extra_tabs.index(current_tab) + 1);
				switch_page(tab);
			}
		}
	}

	public void switch_page_prev(SimpleTab current_tab) {
		if (_tabs.index(current_tab) != -1) {
			if (current_tab == _tabs.first().data) {
				if (tab_extra_num > 0)
					switch_page(_extra_tabs.last().data);
				else
					switch_page(_tabs.last().data);
			} else {
				var tab = _tabs.nth_data(_tabs.index(current_tab) - 1);
				switch_page(tab);
			}
		} else if (_extra_tabs.index(current_tab) != -1) {
			if (current_tab == _extra_tabs.first().data)
				switch_page(_tabs.last().data);
			else {
				var tab = _extra_tabs.nth_data(
					_extra_tabs.index(current_tab) - 1);
				switch_page(tab);
			}
		}
	}

	public void close_page(SimpleTab tab) {
		if (_tabs.index(tab) != -1) {
			_tabs.remove(tab);
			tab_num--;

			if (tab_extra_num > 0) {
				var aux_tab = _extra_tabs.first().data;
				extra_box.remove(aux_tab);
				add_page(aux_tab,false);

				_extra_tabs.remove(aux_tab);
				tab_extra_num--;	
			}
		} else if (_extra_tabs.index(tab) != -1) {
			_extra_tabs.remove(tab);
			tab_extra_num--;
		}

		if ((tab_extra_num == 0) && (tab_num <= 5))
			extra_menu.hide();
		
		// page_closed(tab,get_page_num(tab));
		tab.tab_widget.destroy();
		tab.destroy();
	}

	private void refresh_marked() {
		_tabs.foreach((entry) => {
			entry.refresh_title();
		});

		_extra_tabs.foreach((entry) => {
			entry.refresh_title();
		});
	}

	public int get_page_num(SimpleTab tab) {
		if (_extra_tabs.index(tab) != -1)
			return (_extra_tabs.index(tab) + (int)_tabs.length());
		return _tabs.index(tab);
	}
}