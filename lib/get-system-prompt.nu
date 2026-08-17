export def main [] {
    const current_dir = path self | path dirname

    let prompt = $current_dir
    | path dirname
    | path join '.user' 'prompts'
	| open --raw | str trim
    | path expand
    | ls -f $in
	| where ($it.name | path basename) !~ '^\.'
	| get name
	| each --flatten {|dir| ls $dir }
	| where type == file and ($it.name | str ends-with '.md')
    | input list --fuzzy --display {|dir| $dir.name | path basename }

    $prompt.name | open --raw
}
