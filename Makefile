OUTPUT = simple-text
SOURCES = src/*.vala src/config.vapi 

GETTEXT_PACKAGE = @GETTEXT_PACKAGE@
localedir = @localedir@

OPTIONS = \
	-X -DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-X -DLOCALE_DIR=\""$(localedir)"\" \
	--pkg gtk+-3.0 \
	--pkg gtksourceview-3.0 \
	--pkg gee-0.8 \
	--pkg vte-2.91 \
	--pkg posix

INSTALL_FOLDER = ../$(OUTPUT)
LAUNCHER_FOLDER = ~/.local/share/applications
EXEC_FOLDER = /usr/bin

all: $(OUTPUT)

$(OUTPUT): $(SOURCES)
	valac -o $(OUTPUT) $(OPTIONS) $(SOURCES)

pre_install:
	mkdir $(INSTALL_FOLDER)
	cp LICENSE $(INSTALL_FOLDER)

	glib-compile-schemas data
	cp -r data $(INSTALL_FOLDER)
	cp -r style_schemes $(INSTALL_FOLDER)
	
	install -m755 $(OUTPUT) $(INSTALL_FOLDER)

install: pre_install
	mv $(INSTALL_FOLDER) /opt
	install -m755 $(OUTPUT).desktop $(LAUNCHER_FOLDER)
	install -m755 simple-text $(EXEC_FOLDER)

uninstall:
	rm -rf /opt/$(OUTPUT) $(LAUNCHER_FOLDER)/$(OUTPUT).desktop $(EXEC_FOLDER)/simple-text

run:
	./$(OUTPUT)

clean:
	$(RM) $(OUTPUT)

# version:
# 	printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
