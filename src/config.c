#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <sys/stat.h>
#include <sys/types.h>

char* get_config_dir(void) {
    static char path[PATH_MAX];
    const char *config_home = getenv("XDG_CONFIG_HOME");
    const char *home = getenv("HOME");
    
    if (config_home) {
        snprintf(path, sizeof(path), "%s/hypr-quick-bar", config_home);
    } else if (home) {
        snprintf(path, sizeof(path), "%s/.config/hypr-quick-bar", home);
    } else {
        return NULL;
    }
    
    return path;
}

char* get_config_path(void) {
    static char path[PATH_MAX];
    char *dir = get_config_dir();
    
    if (!dir) {
        return NULL;
    }
    
    snprintf(path, sizeof(path), "%s/%s", dir, CONFIG_FILE_NAME);
    return path;
}

char* get_processed_config_path(void) {
    static char path[PATH_MAX];
    const char *cache_home = getenv("XDG_CACHE_HOME");
    const char *home = getenv("HOME");
    
    if (cache_home) {
        snprintf(path, sizeof(path), "%s/hypr-quick-bar", cache_home);
    } else if (home) {
        snprintf(path, sizeof(path), "%s/.cache/hypr-quick-bar", home);
    } else {
        return NULL;
    }
    
    // Create cache directory if it doesn't exist
    mkdir(path, 0755);
    
    // Append filename
    strncat(path, "/config.json", sizeof(path) - strlen(path) - 1);
    
    return path;
}

// Expand variables in JSON string (e.g., ${HOME}, ${USER})
char* expand_variables(const char *input) {
    size_t capacity = strlen(input) * 2;
    char *output = malloc(capacity);
    if (!output) return NULL;
    
    size_t out_pos = 0;
    const char *p = input;
    
    while (*p) {
        if (p[0] == '$' && p[1] == '{') {
            // Find closing brace
            const char *start = p + 2;
            const char *end = strchr(start, '}');
            if (end) {
                size_t var_len = end - start;
                char var_name[256];
                if (var_len < sizeof(var_name)) {
                    strncpy(var_name, start, var_len);
                    var_name[var_len] = '\0';
                    
                    const char *value = getenv(var_name);
                    if (value) {
                        size_t value_len = strlen(value);
                        // Ensure capacity
                        while (out_pos + value_len >= capacity) {
                            capacity *= 2;
                            char *new_output = realloc(output, capacity);
                            if (!new_output) {
                                free(output);
                                return NULL;
                            }
                            output = new_output;
                        }
                        strcpy(output + out_pos, value);
                        out_pos += value_len;
                        p = end + 1;
                        continue;
                    }
                }
            }
        }
        
        // Ensure capacity
        if (out_pos >= capacity - 1) {
            capacity *= 2;
            char *new_output = realloc(output, capacity);
            if (!new_output) {
                free(output);
                return NULL;
            }
            output = new_output;
        }
        
        output[out_pos++] = *p++;
    }
    
    output[out_pos] = '\0';
    return output;
}

// Process config.json: expand variables and validate JSON
int process_config(void) {
    char *config_file = get_config_path();
    if (!config_file) {
        fprintf(stderr, "cannot determine config path\n");
        return -1;
    }
    
    FILE *in = fopen(config_file, "r");
    if (!in) {
        fprintf(stderr, "cannot open %s: %s\n", config_file, strerror(errno));
        return -1;
    }
    
    // Read entire file
    fseek(in, 0, SEEK_END);
    long file_size = ftell(in);
    fseek(in, 0, SEEK_SET);
    
    char *content = malloc(file_size + 1);
    if (!content) {
        fclose(in);
        return -1;
    }
    
    fread(content, 1, file_size, in);
    content[file_size] = '\0';
    fclose(in);
    
    // Expand variables
    char *processed = expand_variables(content);
    free(content);
    
    if (!processed) {
        fprintf(stderr, "failed to process config\n");
        return -1;
    }
    
    // Basic JSON validation (check for balanced braces)
    int brace_count = 0;
    for (char *p = processed; *p; p++) {
        if (*p == '{') brace_count++;
        else if (*p == '}') brace_count--;
    }
    
    if (brace_count != 0) {
        fprintf(stderr, "invalid JSON in config (unbalanced braces)\n");
        free(processed);
        return -1;
    }
    
    // Write processed config
    char *processed_path = get_processed_config_path();
    if (!processed_path) {
        fprintf(stderr, "cannot determine processed config path\n");
        free(processed);
        return -1;
    }
    
    FILE *out = fopen(processed_path, "w");
    if (!out) {
        fprintf(stderr, "cannot write processed config: %s\n", strerror(errno));
        free(processed);
        return -1;
    }
    
    fwrite(processed, 1, strlen(processed), out);
    fclose(out);
    free(processed);
    
    return 0;
}
