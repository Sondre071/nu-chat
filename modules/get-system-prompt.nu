export def main []: [
	nothing -> string
	nothing -> nothing
]	{
	const project_path = path self | path dirname | path dirname

	const path_file = $project_path | path join '.user' 'prompts'
	let prompts_path = open --raw $path_file | str trim

	let files = ls ($prompts_path | path expand) -f
	| where ($it.name | path basename) !~ '^\.'
	| get name
	| each --flatten {|dir| ls $dir }
	| where type == file and ($it.name | str ends-with '.md')
	| get name
	
	$files | input list --fuzzy -d {|f| $f | path basename}
}
