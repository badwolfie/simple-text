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
	confirm-exit.vala \
	main-window.vala \
	programming-languages.vala \
	simple-header-bar.vala \
	simple-language-picker.vala \
	simple-preferences.vala \
	simple-source-view.vala \
	simple-statusbar.vala \
	simple-tab-bar.vala \
	simple-tab.vala \
	simple-text.vala \
	text-editor.vala \
	$(BUILT_SOURCES)

simple_text_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@simple_text_PACKAGES@

simple_text_LDADD = \
	$(simple_text_LIBS)