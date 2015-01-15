all: simple-text run

simple-text: simple-text-editor.vala main-window.vala
	valac -o simple-text --pkg gtksourceview-3.0 --pkg gtk+-3.0 simple-text-editor.vala main-window.vala

run:
	./simple-text