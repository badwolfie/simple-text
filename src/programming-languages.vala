using Gee;
using Gtk;

public class ProgrammingLanguages {
	private Array<string> buildables;
	SourceLanguageManager lang_manager;

	public ProgrammingLanguages() {
		buildables = new Array<string>();
		lang_manager = SourceLanguageManager.get_default();
		setup_languages();
	}

	private void setup_languages() {
		buildables.append_val("Ada");
		buildables.append_val("ANS-Forth94");
		buildables.append_val("ASP");
		buildables.append_val("BennuGD");
		buildables.append_val("BibTeX");
		buildables.append_val("Bluespec SystemVerilog");
		buildables.append_val("Boo");
		buildables.append_val("C");
		buildables.append_val("C#");
		buildables.append_val("C++");
		buildables.append_val("C/C++/ObjC Header");
		buildables.append_val("CG Shader Language");
		buildables.append_val("COBOL");
		buildables.append_val("CUDA");
		buildables.append_val("D");
		buildables.append_val("Eiffel");
		buildables.append_val("Erlang");
		buildables.append_val("F#");
		buildables.append_val("Forth");
		buildables.append_val("Fortran 95");
		buildables.append_val("Java");
		buildables.append_val("LaTeX");
		buildables.append_val("Lex");
		buildables.append_val("Makefile");
		buildables.append_val("Objective-C");
		buildables.append_val("Vala");
		buildables.append_val("VB.NET");
		buildables.append_val("Verilog");
		buildables.append_val("VHDL");
		buildables.append_val("Yaac");
	}

	public string get_lang_id(string lang_name) {
		string value = "";
		foreach (string lang_id in lang_manager.language_ids) {
			var lang = lang_manager.get_language(lang_id);
			
			if (lang_name == lang.name)
				value = lang_id;
		}
		
		return value;
	}

	public bool is_buildable(string lang_name) {
		for (int i = 0; i < buildables.length; i++)
			if (lang_name == buildables.data[i]) return true;
		return false;
	}
}

