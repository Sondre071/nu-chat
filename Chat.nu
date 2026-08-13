use modules/get-system-prompt.nu

## Setup

const project_dir = path self | path dirname
const history_path = $project_dir | path join 'history.jsonl'

if not ($project_dir | path join '.user' 'logs' | path exists) { mkdir ($project_dir | path join '.user' 'logs') }

let log_file = $project_dir | path join '.user' 'logs' (date now | format date "%Y-%m-%d_%H:%M:%S")
if not ($log_file | path exists) { touch $log_file }

let api_key = open --raw $"($project_dir)/.user/api-key"

let system_prompt = get-system-prompt

if ($history_path | path exists) { rm $history_path }


## Main

mut history = []

if ($system_prompt != null) { $history = [{ role: "system", content: $system_prompt }] }

loop {
	let user_message = input

	print ""

	$history = ($history | append { role: "user", content: $user_message })

	$"\nUser:\n\n($user_message)\n" | save --append $log_file

	let assistant_message = send_message $history | lines | each {|line|
		if ($line =~ '^data: {') {
			let response = $line | str substring 6.. | from json

			if $response.type == 'response.output_text.delta' {
				print --no-newline $"(ansi cyan_bold)($response.delta)"
				$response.delta
			}
		}
	} | str join

	$history = ($history | append { role: "assistant", content: $assistant_message })

	$"\nAssistant:\n\n($assistant_message)\n" | save --append $log_file

	print "\n"
}



def send_message [ history: list<record<role: string, content: string>> ] {
	let payload = { model: 'google/gemini-3.6-flash', stream: true, input: $history }

	$payload | to json -r
	| http post --headers {
		Authorization: $"Bearer ($api_key)"
		Content-Type: application/json
	} https://openrouter.ai/api/v1/responses
}

def save_message [message: string, role: string] {
	let save_path = $"($project_dir)/history.jsonl"

	if $role not-in ['user', 'assistant'] { error make "invalid role" }
	if not ($save_path | path exists) { touch $save_path }

	{ role: $role, message: $message } | to json | save --append $save_path
}
