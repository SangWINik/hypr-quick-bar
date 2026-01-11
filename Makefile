CC = gcc
CFLAGS = -Wall -Wextra -O2 -Isrc
TARGET = hypr-quick-bar
SRCDIR = src
BUILDDIR = build
SRC = $(SRCDIR)/launcher.c $(SRCDIR)/config.c $(SRCDIR)/watcher.c $(SRCDIR)/lib/cJSON/cJSON.c
OBJ = $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(SRC))

all: $(TARGET)

$(TARGET): $(BUILDDIR) $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET)
	rm -rf $(BUILDDIR)

install: $(TARGET)
	install -Dm755 $(TARGET) $(HOME)/.local/bin/$(TARGET)
	rm -rf $(HOME)/.local/share/hypr-quick-bar
	mkdir -p $(HOME)/.local/share/hypr-quick-bar
	cp -r app/* $(HOME)/.local/share/hypr-quick-bar/
	mkdir -p $(HOME)/.config/hypr-quick-bar
	install -Dm644 -T config.json.example $(HOME)/.config/hypr-quick-bar/config.json.example
	@echo "Installed to ~/.local/bin/$(TARGET)"
	@echo "QML files copied to ~/.local/share/hypr-quick-bar/"
	@echo "Example config: ~/.config/hypr-quick-bar/config.json.example"

uninstall:
	rm -f $(HOME)/.local/bin/$(TARGET)
	rm -rf $(HOME)/.local/share/hypr-quick-bar
	@if [ -n "$$XDG_CACHE_HOME" ]; then \
		rm -rf "$$XDG_CACHE_HOME/hypr-quick-bar"; \
	else \
		rm -rf $(HOME)/.cache/hypr-quick-bar; \
	fi
	@echo "Uninstalled hypr-quick-bar"

.PHONY: all clean install uninstall
