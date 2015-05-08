# configure.ac

AC_INIT([simple-text],[0.9.7])
AC_CONFIG_SRCDIR([src/simple-text.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PROG_CC
# AC_PROG_CC_STDC
AM_PROG_VALAC([0.24])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.35])

pkg_modules="gtk+-3.0 >= 3.10.0"
PKG_CHECK_MODULES(simple_text, [$pkg_modules])
AC_SUBST(simple_text_CFLAGS)
AC_SUBST(simple_text_LIBS)
# AC_SUBST(simple_text_PACKAGES)

GETTEXT_PACKAGE=simple-text
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	po/Makefile.in
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT