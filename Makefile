CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = hypr-quick-bar
SRC = launcher.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -Dm755 $(TARGET) $(HOME)/.local/bin/$(TARGET)

uninstall:
	rm -f $(HOME)/.local/bin/$(TARGET)

.PHONY: all clean install uninstall
