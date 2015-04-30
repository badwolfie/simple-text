OUTPUT = simple-text
SOURCES = src/*.vala
OPTIONS = --pkg gtk+-3.0 --pkg gtksourceview-3.0 --pkg gee-0.8 --pkg vte-2.91 --pkg posix

INSTALL_FOLDER=/opt/Simple-text
LAUNCHER_FOLDER=/usr/share/applications
EXEC_FOLDER=/usr/bin

all: $(OUTPUT)

$(OUTPUT): $(SOURCES)
	valac -o $(OUTPUT) $(OPTIONS) $(SOURCES)

install:
	-mkdir $(INSTALL_FOLDER)
	cp -r style_schemes $(INSTALL_FOLDER)
	cp -r resources $(INSTALL_FOLDER)
	cp $(OUTPUT) $(INSTALL_FOLDER)
	cp LICENSE $(INSTALL_FOLDER)

	cp $(OUTPUT).desktop $(LAUNCHER_FOLDER)
	chmod +x $(LAUNCHER_FOLDER)/$(OUTPUT).desktop
	
	ln -s $(INSTALL_FOLDER)/$(OUTPUT) $(EXEC_FOLDER)/$(OUTPUT)

uninstall:
	rm -rf $(INSTALL_FOLDER) $(LAUNCHER_FOLDER)/$(OUTPUT).desktop $(EXEC_FOLDER)/$(OUTPUT)

run:
	./$(OUTPUT)

clean:
	$(RM) $(OUTPUT)
