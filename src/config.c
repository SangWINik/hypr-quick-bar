#include <stdbool.h>
#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <ctype.h>
#include <assert.h>
#include "lib/cJSON/cJSON.h"

struct kv { char key[256]; char value[1024]; };

static char custom_config_dir[PATH_MAX] = "";
static char custom_cache_dir[PATH_MAX] = "";

void set_config_dir(const char *dir) {
    if (dir) {
        strncpy(custom_config_dir, dir, sizeof(custom_config_dir) - 1);
        custom_config_dir[sizeof(custom_config_dir) - 1] = '\0';
    } else {
        custom_config_dir[0] = '\0';
    }
}

void set_cache_dir(const char *dir) {
    if (dir) {
        strncpy(custom_cache_dir, dir, sizeof(custom_cache_dir) - 1);
        custom_cache_dir[sizeof(custom_cache_dir) - 1] = '\0';
    } else {
        custom_cache_dir[0] = '\0';
    }
}

char* get_config_dir(void) {
    static char path[PATH_MAX];
    if (custom_config_dir[0]) {
        strncpy(path, custom_config_dir, sizeof(path) - 1);
        path[sizeof(path) - 1] = '\0';
        return path;
    }
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
    if (custom_cache_dir[0]) {
        strncpy(path, custom_cache_dir, sizeof(path) - 1);
        path[sizeof(path) - 1] = '\0';
    } else {
        const char *cache_home = getenv("XDG_CACHE_HOME");
        const char *home = getenv("HOME");
        if (cache_home) {
            snprintf(path, sizeof(path), "%s/hypr-quick-bar", cache_home);
        } else if (home) {
            snprintf(path, sizeof(path), "%s/.cache/hypr-quick-bar", home);
        } else {
            return NULL;
        }
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

// Helper: recursively flatten JSON into key-value pairs with dot notation
static int flatten_json(const char *json, char *prefix, struct kv *map, int *map_count, int max_count) {
    const char *p = json;
    while (*p) {
        while (*p && *p != '"') p++;
        if (!*p) break;
        const char *kstart = ++p;
        while (*p && *p != '"') p++;
        int klen = p - kstart;
        if (*p == '"') p++;
        while (*p && (*p == ' ' || *p == ':')) p++;
        if (*p == '{') {
            // Nested object
            char newprefix[256];
            if (prefix && *prefix)
                snprintf(newprefix, sizeof(newprefix), "%s.%.*s", prefix, klen, kstart);
            else
                snprintf(newprefix, sizeof(newprefix), "%.*s", klen, kstart);
            // Find matching closing brace
            int depth = 1;
            const char *objstart = ++p;
            const char *objend = objstart;
            while (*objend && depth > 0) {
                if (*objend == '{') depth++;
                else if (*objend == '}') depth--;
                objend++;
            }
            int objlen = objend - objstart - 1;
            char *subjson = malloc(objlen + 1);
            strncpy(subjson, objstart, objlen);
            subjson[objlen] = '\0';
            flatten_json(subjson, newprefix, map, map_count, max_count);
            free(subjson);
            p = objend;
            continue;
        }
        if (*p == '"') {
            // Value
            const char *vstart = ++p;
            while (*p && *p != '"') p++;
            int vlen = p - vstart;
            if (*p == '"') p++;
            char key[256];
            if (prefix && *prefix)
                snprintf(key, sizeof(key), "%s.%.*s", prefix, klen, kstart);
            else
                snprintf(key, sizeof(key), "%.*s", klen, kstart);
            if (*map_count < max_count && vlen < 1024) {
                strncpy(map[*map_count].key, key, sizeof(map[*map_count].key)-1);
                map[*map_count].key[sizeof(map[*map_count].key)-1] = '\0';
                strncpy(map[*map_count].value, vstart, vlen);
                map[*map_count].value[vlen] = '\0';
                (*map_count)++;
            }
        }
    }
    return 0;
}

char* substitute_templates(const char *input, const char *env_json_str) {
    if (!input || !env_json_str) return NULL;
    struct kv { char key[256]; char value[1024]; } map[256];
    int map_count = 0;
    flatten_json(env_json_str, NULL, map, &map_count, 256);
    size_t outcap = strlen(input) * 2 + 1;
    char *output = malloc(outcap);
    if (!output) return NULL;
    size_t outpos = 0;
    for (const char *q = input; *q;) {
        if (q[0] == '{' && q[1] == '{') {
            const char *start = q + 2;
            const char *end = strstr(start, "}}");
            if (end) {
                int tlen = end - start;
                char tkey[256];
                if (tlen > 0 && tlen < (int)sizeof(tkey)) {
                    strncpy(tkey, start, tlen);
                    tkey[tlen] = '\0';
                    // Lookup
                    const char *val = NULL;
                    for (int i = 0; i < map_count; ++i) {
                        if (strcmp(map[i].key, tkey) == 0) {
                            val = map[i].value;
                            break;
                        }
                    }
                    if (val) {
                        size_t vlen = strlen(val);
                        while (outpos + vlen >= outcap) {
                            outcap *= 2;
                            char *newout = realloc(output, outcap);
                            if (!newout) { free(output); return NULL; }
                            output = newout;
                        }
                        strcpy(output + outpos, val);
                        outpos += vlen;
                        q = end + 2;
                        continue;
                    }
                }
            }
        }
        // Copy one char
        if (outpos + 1 >= outcap) {
            outcap *= 2;
            char *newout = realloc(output, outcap);
            if (!newout) { free(output); return NULL; }
            output = newout;
        }
        output[outpos++] = *q++;
    }
    output[outpos] = '\0';
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

    // Use cJSON to parse config and check for environmentFile
    cJSON *root = cJSON_Parse(content);
    if (!root) {
        fprintf(stderr, "invalid JSON in config\n");
        free(content);
        return -1;
    }
    cJSON *envFile = cJSON_GetObjectItem(root, "environmentFile");
    char *env_json_str = NULL;
    if (envFile && cJSON_IsString(envFile)) {
        // Expand ~ in path
        const char *env_path = envFile->valuestring;
        char expanded_path[PATH_MAX];
        if (env_path[0] == '~') {
            const char *home = getenv("HOME");
            if (!home) {
                fprintf(stderr, "HOME not set for environmentFile\n");
                cJSON_Delete(root);
                free(content);
                return -1;
            }
            snprintf(expanded_path, sizeof(expanded_path), "%s%s", home, env_path + 1);
        } else {
            strncpy(expanded_path, env_path, sizeof(expanded_path) - 1);
            expanded_path[sizeof(expanded_path) - 1] = '\0';
        }
        FILE *envf = fopen(expanded_path, "r");
        if (!envf) {
            fprintf(stderr, "cannot open environmentFile %s: %s\n", expanded_path, strerror(errno));
            cJSON_Delete(root);
            free(content);
            return -1;
        }
        fseek(envf, 0, SEEK_END);
        long env_size = ftell(envf);
        fseek(envf, 0, SEEK_SET);
        env_json_str = malloc(env_size + 1);
        if (!env_json_str) {
            fclose(envf);
            cJSON_Delete(root);
            free(content);
            return -1;
        }
        fread(env_json_str, 1, env_size, envf);
        env_json_str[env_size] = '\0';
        fclose(envf);
    }

    // Expand variables
    char *processed = expand_variables(content);
    if (!processed) {
        cJSON_Delete(root);
        free(content);
        if (env_json_str) free(env_json_str);
        fprintf(stderr, "failed to process config\n");
        return -1;
    }
    // Substitute templates if env_json_str is available
    char *templated = NULL;
    if (env_json_str) {
        templated = substitute_templates(processed, env_json_str);
        free(processed);
        free(env_json_str);
        if (!templated) {
            cJSON_Delete(root);
            free(content);
            fprintf(stderr, "failed to substitute templates\n");
            return -1;
        }
    } else {
        templated = processed;
    }
    free(content);
    cJSON_Delete(root);

    // Basic JSON validation (check for balanced braces)
    int brace_count = 0;
    for (char *p = templated; *p; p++) {
        if (*p == '{') brace_count++;
        else if (*p == '}') brace_count--;
    }
    if (brace_count != 0) {
        fprintf(stderr, "invalid JSON in config (unbalanced braces)\n");
        free(templated);
        return -1;
    }
    // Write processed config
    char *processed_path = get_processed_config_path();
    if (!processed_path) {
        fprintf(stderr, "cannot determine processed config path\n");
        free(templated);
        return -1;
    }
    FILE *out = fopen(processed_path, "w");
    if (!out) {
        fprintf(stderr, "cannot write processed config: %s\n", strerror(errno));
        free(templated);
        return -1;
    }
    fwrite(templated, 1, strlen(templated), out);
    fclose(out);
    free(templated);
    return 0;
}
