#ifndef WATCHER_H
#define WATCHER_H

#include <sys/types.h>

// Callback function type for file change events
typedef void (*file_change_callback_t)(void);

// Initialize file watcher for a directory, watching for specific filename
// Returns file descriptor on success, -1 on error
int watcher_init(const char *dirpath, const char *filename);

// Check for file changes (non-blocking)
// Calls callback if watched file was modified
// Returns 0 on success, -1 on error
int watcher_check(int fd, file_change_callback_t callback);

// Cleanup watcher
void watcher_cleanup(int fd);

#endif // WATCHER_H
