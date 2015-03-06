using Gee;

public class ProgrammingLanguages {
	private HashMap<string,string> lang_ext;
	private HashMap<string,string> lang_names;
	private Array<string> buildables;

	public ProgrammingLanguages() {
		lang_ext = new HashMap<string,string>();
		lang_names = new HashMap<string,string>();
		buildables = new Array<string>();
		setup_languages();
	}

	private void setup_languages() {
		lang_ext.set("c","c");
		lang_ext.set("h","cpp");
		lang_ext.set("cc","cpp");
		lang_ext.set("cpp","cpp");
		lang_ext.set("sh","sh");
		lang_ext.set("pl","perl");
		lang_ext.set("php","php");
		lang_ext.set("xml","xml");
		lang_ext.set("ui","xml");
		lang_ext.set("tex","latex");
		lang_ext.set("py","python");
		lang_ext.set("java","java");
		lang_ext.set("html","html");
		lang_ext.set("cs","c-sharp");
		lang_ext.set("bib","bibtex");
		lang_ext.set("css","css");
		lang_ext.set("desktop","desktop");
		lang_ext.set("js","js");
		lang_ext.set("json","json");
		lang_ext.set("lex","lex");
		lang_ext.set("l","lex");
		lang_ext.set("Makefile","makefile");
		lang_ext.set("md","markdown");
		lang_ext.set("m","matlab");
		lang_ext.set("rb","ruby");
		lang_ext.set("sql","sql");
		lang_ext.set("vala","vala");
		lang_ext.set("vapi","vala");
		lang_ext.set("vhd","vhdl");
		lang_ext.set("xslt","xslt");
		lang_ext.set("y","yacc");
		lang_ext.set("yaac","yacc");


		lang_names.set("c","C");
		lang_names.set("h","C++");
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

	public virtual string get_lang_id(string filename) {
		return lang_ext[get_file_extension(filename)];
	}

	public virtual string get_lang_name(string filename) {
		return lang_names[get_file_extension(filename)];
	}

	public virtual bool is_buildable(string filename) {
		string l_name = lang_names[get_file_extension(filename)];
		for (int i = 0; i < buildables.length; i++)
			if (l_name == buildables.data[i]) return true;
		return false;
	}
}