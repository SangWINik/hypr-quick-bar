#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>
#include <time.h>
#include "config.h"
#include "watcher.h"

#define PROGRAM_NAME "hypr-quick-bar"
#define DEFAULT_APP_DIR "%s/.local/share/hypr-quick-bar"
#define RELOAD_DEBOUNCE_MS 500

static volatile sig_atomic_t child_pid = 0;
static char app_dir[4096] = {0};
static time_t last_reload_time = 0;
static int watch_config = 0;  // Disable watching by default

// Forward declarations
static void run_quickshell(void);
static void print_help(const char *program_name);

void handle_kill_signal(int sig) {
    if (child_pid > 0) {
        kill(child_pid, sig);
    }
}

static void print_help(const char *program_name) {
    printf("Usage: %s [OPTIONS]\n", program_name);
    printf("\nOptions:\n");
    printf("  -d, --app-dir DIR   QML application directory (default: ~/.local/share/hypr-quick-bar)\n");
    printf("  -w, --watch         Enable config file watching\n");
    printf("  -h, --help          Show this help message\n");
}

static void on_config_changed(void) {
    // Debounce: ignore rapid successive changes
    time_t now = time(NULL);
    if (now - last_reload_time < 1) {
        fprintf(stderr, "%s: debouncing config change (too soon)\n", PROGRAM_NAME);
        return;
    }
    last_reload_time = now;
    
    fprintf(stderr, "%s: config file changed, reprocessing and restarting...\n", PROGRAM_NAME);
    
    // Process config
    if (process_config() == 0) {
        // Kill current quickshell
        if (child_pid > 0) {
            kill(child_pid, SIGTERM);
            waitpid(child_pid, NULL, 0);
        }
        
        // Restart quickshell
        child_pid = fork();
        if (child_pid == 0) {
            run_quickshell();
        } else if (child_pid < 0) {
            fprintf(stderr, "%s: fork failed: %s\n", PROGRAM_NAME, strerror(errno));
        } else {
            fprintf(stderr, "%s: restarted quickshell (pid %d)\n", PROGRAM_NAME, child_pid);
        }
    }
}

static void run_quickshell(void) {
    char main_qml_path[4096];
    snprintf(main_qml_path, sizeof(main_qml_path), "%s/main.qml", app_dir);
    
    char *args[] = {
        "quickshell",
        "--path", main_qml_path,
        NULL
    };
    
    execvp("quickshell", args);
    
    // Only reached if exec fails
    fprintf(stderr, "%s: exec failed: %s\n", PROGRAM_NAME, strerror(errno));
    exit(1);
}

static void run_parent(void) {
    signal(SIGTERM, handle_kill_signal);
    signal(SIGINT, handle_kill_signal);
    
    int watcher_fd = -1;
    
    // Setup file watcher if enabled
    if (watch_config) {
        char *config_dir = get_config_dir();
        if (!config_dir) {
            fprintf(stderr, "%s: failed to determine config directory\n", PROGRAM_NAME);
            return;
        }
        
        fprintf(stderr, "Watching config directory: %s\n", config_dir);
        
        watcher_fd = watcher_init(config_dir, "config.json");
        if (watcher_fd < 0) {
            fprintf(stderr, "%s: failed to initialize file watcher\n", PROGRAM_NAME);
            return;
        }
    } else {
        fprintf(stderr, "Config file watching disabled\n");
    }
    
    while (1) {
        // Check for config file changes (only if watching is enabled)
        if (watch_config && watcher_fd >= 0) {
            watcher_check(watcher_fd, on_config_changed);
        }
        
        // Check if child exited
        int status;
        pid_t result = waitpid(child_pid, &status, WNOHANG);
        if (result > 0) {
            // Child exited, we exit too
            break;
        }
        
        usleep(100000); // Sleep 100ms
    }
    
    if (watcher_fd >= 0) {
        watcher_cleanup(watcher_fd);
    }
}

int main(int argc, char *argv[]) {
    // Set default app directory
    const char *home = getenv("HOME");
    if (!home) {
        fprintf(stderr, "%s: HOME environment variable not set\n", PROGRAM_NAME);
        return 1;
    }
    snprintf(app_dir, sizeof(app_dir), DEFAULT_APP_DIR, home);
    
    // Parse arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--app-dir") == 0 || strcmp(argv[i], "-d") == 0) {
            if (i + 1 < argc) {
                strncpy(app_dir, argv[++i], sizeof(app_dir) - 1);
            } else {
                fprintf(stderr, "%s: --app-dir requires a path argument\n", PROGRAM_NAME);
                return 1;
            }
        } else if (strcmp(argv[i], "--watch") == 0 || strcmp(argv[i], "-w") == 0) {
            watch_config = 1;
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            print_help(PROGRAM_NAME);
            return 0;
        } else {
            fprintf(stderr, "%s: unknown option: %s\n", PROGRAM_NAME, argv[i]);
            fprintf(stderr, "Try '%s --help' for more information.\n", PROGRAM_NAME);
            return 1;
        }
    }
    
    // Update argv[0] for process name
    if (argc > 0) {
        strncpy(argv[0], PROGRAM_NAME, strlen(argv[0]));
    }

    // Process config on startup
    if (process_config() != 0) {
        fprintf(stderr, "%s: failed to process initial config\n", PROGRAM_NAME);
        return 1;
    }

    child_pid = fork();

    if (child_pid < 0) {
        fprintf(stderr, "%s: fork failed: %s\n", PROGRAM_NAME, strerror(errno));
        return 1;
    }

    if (child_pid == 0) {
        run_quickshell();  // Never returns
    }

    run_parent();
    return 0;
}
