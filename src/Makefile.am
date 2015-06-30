bin_PROGRAMS = simple-text

AM_CPPFLAGS = \
	-include config.h \
	$(simple_text_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR.=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" 

BUILT_SOURCES = resources.c

resources.c: $(top_srcdir)/data/simple-text.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data/ $(top_srcdir)/data/simple-text.gresource.xml)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data/ --generate-source $<

simple_text_SOURCES = \
	st-application.vala \
	st-header-bar.vala \
	st-language-picker.vala \
	st-main-window.vala \
	st-preferences-dialog.vala \
	st-programming-languages.vala \
	st-source-style-picker.vala \
	st-source-view.vala \
	st-statusbar.vala \
	st-tab-bar.vala \
	st-tab.vala \
	st-text-editor.vala \
	$(BUILT_SOURCES)

simple_text_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@simple_text_PACKAGES@

simple_text_LDADD = \
	$(simple_text_LIBS)
