function pwd_info -a separator -d "Print easy-to-parse information the current working directory"
    set -l home ~
    set -l git_root (command git rev-parse --show-toplevel ^ /dev/null)

    command pwd -P | awk -v home="$home" -v git_root="$git_root" -v separator="$separator" -v dir_length="$fish_prompt_pwd_dir_length" '
        function base(string) {
            sub(/^\/?.*\//, "", string)
            return string
        }
        function dir_abbr(dir) {
            abbr = dir_length == 0 ? dir : substr(dir, 1, dir_length ? dir_length : 1)
            # Just "." can happen depending on the value of `dir_length`
            # This is not very informative, so add an additional character
            name = abbr == "." ? substr(dir, 1, 2) : abbr
            return name
        }
        function dirs(string, printLastName, prefix, path) {
            len = split(string, parts, "/")
            for (i = 1; i < len; i++) {
                if (parts[i] == "") {
                    continue
                }
                name = dir_abbr(parts[i])
                path = path prefix name
                prefix = separator
            }
            return (printLastName == 1) ? path prefix parts[len] : path
        }
        function remove(thisString, fromString) {
            sub(thisString, "", fromString)
            return fromString
        }
        {
            if (git_root == home) {
                git_root = ""
            }
            if (git_root == "") {
                printf("%s\n%s\n%s\n",
                    $0 == home || $0 == "/" ? "" : base($0),
                    dirs(remove(home, $0)), "")
            } else {
                printf("%s\n%s\n%s\n",
                    base(git_root),
                    dirs(remove(home, git_root)),
                    $0 == git_root ? "" : dirs(remove(git_root, $0), 1))
            }
        }
    '
end
