# configure.ac

AC_INIT([simple-text],[0.9.7])
AC_CONFIG_SRCDIR([src/simple-text.vala])
AC_CONFIG_HEADERS([config.h])

# AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
GNOME_MAINTAINER_MODE_DEFINES

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

GLIB_GSETTINGS

AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_VALAC([0.24])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.50.1])

pkg_modules="gtk+-3.0 >= 3.10.0 gtksourceview-3.0 >= 3.16.1 gee-0.8 >= 0.18.0 vte-2.91 >= 0.40.0"
simple_text_PACKAGES="--pkg gtk+-3.0 --pkg gtksourceview-3.0 --pkg gee-0.8 --pkg vte-2.91 --pkg posix --target-glib 2.32"
PKG_CHECK_MODULES(simple_text, [$pkg_modules])
AC_SUBST(simple_text_CFLAGS)
AC_SUBST(simple_text_LIBS)
AC_SUBST(simple_text_PACKAGES)

GETTEXT_PACKAGE=simple-text
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	po/Makefile.in
	data/Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT