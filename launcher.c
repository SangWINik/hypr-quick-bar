#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>

#define PROGRAM_NAME "hypr-quick-bar"
#define CONFIG_DIR "/home/maksym/.config/quickshell/bar"

static volatile sig_atomic_tpk child_pid = 0;

void handle_kill_signal(int sig) {
    if (child_pid > 0) {
        kill(child_pid, sig);
    }
}

static void run_quickshell(void) {
    char *args[] = {
        "quickshell",
        "--path", CONFIG_DIR "/main.qml",
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
    
    wait(NULL);
}

int main(int argc, char *argv[]) {
    if (argc > 0) {
        strncpy(argv[0], PROGRAM_NAME, strlen(argv[0]));
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
