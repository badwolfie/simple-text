all: simple-text run

simple-text: simple-text-editor.vala main-window.vala confirm-exit.vala simle-source-view.vala
	valac -o simple-text --pkg gedit --pkg gtk+-3.0 simple-text-editor.vala main-window.vala confirm-exit.vala simle-source-view.vala

run:
	./simple-text