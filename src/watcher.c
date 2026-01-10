#include "watcher.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/inotify.h>

#define EVENT_SIZE (sizeof(struct inotify_event))
#define EVENT_BUF_LEN (1024 * (EVENT_SIZE + 16))

static int watch_descriptor = -1;
static char watched_filename[256] = {0};

int watcher_init(const char *dirpath, const char *filename) {
    int fd = inotify_init1(IN_NONBLOCK);
    if (fd < 0) {
        fprintf(stderr, "inotify_init failed: %s\n", strerror(errno));
        return -1;
    }
    
    // Store filename to watch for
    strncpy(watched_filename, filename, sizeof(watched_filename) - 1);
    
    // Watch directory for: file writes, file creation, file moves (for atomic writes by editors)
    watch_descriptor = inotify_add_watch(fd, dirpath, IN_MODIFY | IN_CLOSE_WRITE | IN_CREATE | IN_MOVED_TO);
    if (watch_descriptor < 0) {
        fprintf(stderr, "inotify_add_watch failed: %s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    return fd;
}

int watcher_check(int fd, file_change_callback_t callback) {
    char event_buf[EVENT_BUF_LEN];
    
    int length = read(fd, event_buf, EVENT_BUF_LEN);
    if (length < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
            // No events available (non-blocking)
            return 0;
        }
        fprintf(stderr, "inotify read failed: %s\n", strerror(errno));
        return -1;
    }
    
    if (length > 0) {
        int triggered = 0;
        int i = 0;
        while (i < length) {
            struct inotify_event *event = (struct inotify_event *)&event_buf[i];
            
            // Check if it's the watched file being modified/created/moved
            if (event->len > 0 && strcmp(event->name, watched_filename) == 0) {
                if (event->mask & (IN_MODIFY | IN_CLOSE_WRITE | IN_CREATE | IN_MOVED_TO)) {
                    triggered = 1;
                }
            }
            i += EVENT_SIZE + event->len;
        }
        
        // Call callback once after processing all events
        if (triggered && callback) {
            callback();
        }
    }
    
    return 0;
}

void watcher_cleanup(int fd) {
    if (watch_descriptor >= 0) {
        inotify_rm_watch(fd, watch_descriptor);
        watch_descriptor = -1;
    }
    if (fd >= 0) {
        close(fd);
    }
}
