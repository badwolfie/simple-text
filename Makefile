OUTPUT = simple-text
SOURCES = *.vala
OPTIONS = --pkg gtk+-3.0 --pkg gtksourceview-3.0

all: $(OUTPUT) run

$(OUTPUT): $(SOURCES)
	valac -o $(OUTPUT) $(OPTIONS) $(SOURCES)

clean:
	rm $(OUTPUT)

run:
	./$(OUTPUT)