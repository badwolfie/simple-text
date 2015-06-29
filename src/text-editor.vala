public class TextEditor : Object {
	private bool _show_line_numbers;
	public bool show_line_numbers {
		get { return _show_line_numbers; }
		set {
			if (_show_line_numbers != value)
				_show_line_numbers = value;
		}
	}

	private bool _show_right_margin;
	public bool show_right_margin {
		get { return _show_right_margin; }
		set {
			if (_show_right_margin != value)
				_show_right_margin = value;
		}
	}

	private int _right_margin_at;
	public int right_margin_at {
		get { return _right_margin_at; }
		set {
			if (_right_margin_at != value)
				_right_margin_at = value;
		}
	}

	private bool _use_text_wrap;
	public bool use_text_wrap {
		get { return _use_text_wrap; }
		set {
			if (_use_text_wrap != value)
				_use_text_wrap = value;
		}
	}

	private bool _highlight_current_line;
	public bool highlight_current_line {
		get { return _highlight_current_line; }
		set {
			if (_highlight_current_line != value)
				_highlight_current_line = value;
		}
	}

	private bool _highlight_brackets;
	public bool highlight_brackets {
		get { return _highlight_brackets; }
		set {
			if (_highlight_brackets != value)
				_highlight_brackets = value;
		}
	}

	
	private int _tab_width;
	public int tab_width {
		get { return _tab_width; }
		set {
			if (_tab_width != value)
				_tab_width = value;
		}
	}

	private bool _insert_spaces;
	public bool insert_spaces {
		get { return _insert_spaces; }
		set {
			if (_insert_spaces != value)
				_insert_spaces = value;
		}
	}

	private bool _auto_indent;
	public bool auto_indent {
		get { return _auto_indent; }
		set {
			if (_auto_indent != value)
				_auto_indent = value;
		}
	}

	private bool _show_grid_pattern;
	public bool show_grid_pattern {
		get { return _show_grid_pattern; }
		set {
			if (_show_grid_pattern != value)
				_show_grid_pattern = value;
		}
	}
	
	private bool _use_default_typo;
	public bool use_default_typo {
		get { return _use_default_typo; }
		set {
			if (_use_default_typo != value)
				_use_default_typo = value;
		}
	}

	private string _editor_font;
	public string editor_font {
		get { return _editor_font; }
		set {
			if (_editor_font != value)
				_editor_font = value;
		}
	}

	private string _color_scheme;
	public string color_scheme {
		get { return _color_scheme; }
		set {
			if (_color_scheme != value)
				_color_scheme = value;
		}
	}

	private bool _prefer_dark;
	public bool prefer_dark {
		get { return _prefer_dark; }
		set {
			if (_prefer_dark != value)
				_prefer_dark = value;
		}
	}
	
	private bool _save_workspace;
	public bool save_workspace {
		get { return _save_workspace; }
		set {
			if (_save_workspace != value)
				_save_workspace = value;
		}
	}
	
	private bool _show_welcome;
	public bool show_welcome {
		get { return _show_welcome; }
		set {
			if (_show_welcome != value)
				_show_welcome = value;
		}
	}
}

