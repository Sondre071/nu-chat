export def main []: nothing -> oneof<string, nothing> {
    let prompt = $env.prompts_path_file
	| open --raw | str trim
    | path expand
    | ls -f $in
    | where $it.type == dir and ($it.name | path basename) !~ '^\.'
    | each --flatten {|dir| ls $dir.name}
	| where type == file and ($it.name | str ends-with '.md')
    | input list --fuzzy --display {|file| $file.name | path basename }

    if $prompt != null {
        $prompt.name | open --raw
    }
}
