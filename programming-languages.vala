using Gee;

public class ProgrammingLanguages {
	private HashMap<string,string> lang_ids;
	private HashMap<string,string> lang_names;
	private HashMap<string,string> lang_ext;
	private Array<string> buildables;

	public ProgrammingLanguages() {
		lang_ids = new HashMap<string,string>();
		lang_names = new HashMap<string,string>();
		lang_ext = new HashMap<string,string>();
		buildables = new Array<string>();
		setup_languages();
	}

	private void setup_languages() {
		lang_ids.set("c","c");
		lang_ids.set("h","cpp");
		lang_ids.set("cc","cpp");
		lang_ids.set("cpp","cpp");
		lang_ids.set("sh","sh");
		lang_ids.set("pl","perl");
		lang_ids.set("php","php");
		lang_ids.set("xml","xml");
		lang_ids.set("ui","xml");
		lang_ids.set("tex","latex");
		lang_ids.set("py","python");
		lang_ids.set("java","java");
		lang_ids.set("html","html");
		lang_ids.set("cs","c-sharp");
		lang_ids.set("bib","bibtex");
		lang_ids.set("css","css");
		lang_ids.set("desktop","desktop");
		lang_ids.set("js","js");
		lang_ids.set("json","json");
		lang_ids.set("lex","lex");
		lang_ids.set("l","lex");
		lang_ids.set("Makefile","makefile");
		lang_ids.set("md","markdown");
		lang_ids.set("m","matlab");
		lang_ids.set("rb","ruby");
		lang_ids.set("sql","sql");
		lang_ids.set("vala","vala");
		lang_ids.set("vapi","vala");
		lang_ids.set("vhd","vhdl");
		lang_ids.set("xslt","xslt");
		lang_ids.set("y","yacc");
		lang_ids.set("yaac","yacc");


		lang_names.set("c","C");
		lang_names.set("h","C/C++ header file");
		lang_names.set("cc","C++");
		lang_names.set("cpp","C++");
		lang_names.set("sh","Shell script");
		lang_names.set("pl","Perl");
		lang_names.set("php","PHP");
		lang_names.set("xml","XML");
		lang_names.set("tex","LaTeX");
		lang_names.set("py","Python");
		lang_names.set("java","Java");
		lang_names.set("html","HTML");
		lang_names.set("cs","C#");
		lang_names.set("bib","Bibtex");
		lang_names.set("css","CSS");
		lang_names.set("desktop","Desktop");
		lang_names.set("js","Javascript");
		lang_names.set("json","JSon");
		lang_names.set("lex","Lex");
		lang_names.set("l","Flex");
		lang_names.set("Makefile","Makefile");
		lang_names.set("md","Markdown");
		lang_names.set("m","MatLab");
		lang_names.set("rb","Ruby");
		lang_names.set("sql","SQL");
		lang_names.set("vala","Vala");
		lang_names.set("vapi","Vapi");
		lang_names.set("vhd","VHDL");
		lang_names.set("xslt","XSLT");
		lang_names.set("y","Bison");
		lang_names.set("yaac","YAAC");
		lang_names.set("ui","Glade UI");


		lang_ext.set("C",".c");
		lang_ext.set("C/C++ header file",".h");
		lang_ext.set("C++",".cc");
		lang_ext.set("C++",".cpp");
		lang_ext.set("Shell script",".sh");
		lang_ext.set("Perl",".pl");
		lang_ext.set("PHP",".php");
		lang_ext.set("XML",".xml");
		lang_ext.set("LaTeX",".tex");
		lang_ext.set("Python",".py");
		lang_ext.set("Java",".java");
		lang_ext.set("HTML",".html");
		lang_ext.set("C#",".cs");
		lang_ext.set("Bibtex",".bib");
		lang_ext.set("CSS",".css");
		lang_ext.set("Desktop",".desktop");
		lang_ext.set("Javascript",".js");
		lang_ext.set("JSon",".json");
		lang_ext.set("Lex",".lex");
		lang_ext.set("Flex",".l");
		lang_ext.set("Makefile",".Makefile");
		lang_ext.set("Markdown",".md");
		lang_ext.set("MatLab",".m");
		lang_ext.set("Ruby",".rb");
		lang_ext.set("SQL",".sql");
		lang_ext.set("Vala",".vala");
		lang_ext.set("Vapi",".vapi");
		lang_ext.set("VHDL",".vhd");
		lang_ext.set("XSLT",".xslt");
		lang_ext.set("Bison",".y");
		lang_ext.set("YAAC",".yaac");
		lang_ext.set("Glade UI",".ui");


		buildables.append_val("C");
		buildables.append_val("C++");
		buildables.append_val("LaTeX");
		buildables.append_val("Java");
		buildables.append_val("C#");
		buildables.append_val("Lex");
		buildables.append_val("Flex");
		buildables.append_val("Vala");
		buildables.append_val("Vapi");
		buildables.append_val("VHDL");
		buildables.append_val("Bison");
		buildables.append_val("YAAC");
	}

	private string get_file_extension(string filename) {
		if (filename.contains("Makefile"))
			return "Makefile";

		var components = filename.split(".");
		return components[components.length - 1];
	}

	public string get_lang_id(string filename) {
		return lang_ids[get_file_extension(filename)];
	}

	public string get_lang_name(string filename) {
		return lang_names[get_file_extension(filename)];
	}

	public string get_lang_ext(string lang_name) {
		if (lang_name == "Plain text") return "";
		return lang_ext[lang_name];
	}

	public bool is_buildable(string filename) {
		string l_name = lang_names[get_file_extension(filename)];
		for (int i = 0; i < buildables.length; i++)
			if (l_name == buildables.data[i]) return true;
		return false;
	}
}