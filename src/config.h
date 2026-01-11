// Set custom config directory (overrides XDG_CONFIG_HOME)
void set_config_dir(const char *dir);

// Set custom cache directory (overrides XDG_CACHE_HOME)
void set_cache_dir(const char *dir);
#ifndef CONFIG_H
#define CONFIG_H

#define CONFIG_FILE_NAME "config.json"

// Get config file path (looks in XDG_CONFIG_HOME or ~/.config)
char* get_config_path(void);

// Get config directory path
char* get_config_dir(void);

// Get processed config path (XDG_CACHE_HOME or ~/.cache)
char* get_processed_config_path(void);

// Expand environment variables in a string (e.g., ${HOME}, ${USER})
// Returns newly allocated string that must be freed, or NULL on error
char* expand_variables(const char *input);

// Substitute {{section.key}} or {{key}} in input using values from env_json (must be a flat JSON object or nested objects)
// Returns a newly allocated string, or NULL on error
char* substitute_templates(const char *input, const char *env_json_str);

// Process config.json: expand variables, validate JSON, write processed output
// Returns 0 on success, -1 on error
int process_config(void);

#endif // CONFIG_H
