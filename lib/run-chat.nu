use ./get-system-prompt.nu


mut history: table<role: string, content: string> = get-system-prompt
| if $in != null {
    [{ role: "system", content: $in }]
} else {
    []
}

loop {
	let user_message = input

	print ''

	$history = ($history | append { role: "user", content: $user_message })

	$"\nUser:\n\n($user_message)\n" | save --append $env.log_file


	let assistant_message = { model: $env.model, stream: true, input: $history }
    | to json -r
	| http post --headers {
		Authorization: $"Bearer ($env.api_key)"
		Content-Type: application/json
	} https://openrouter.ai/api/v1/responses
    | lines | each {|line|
		if ($line =~ '^data: {') {
			let response = $line | str substring 6.. | from json

			if $response.type == 'response.output_text.delta' {
				print --no-newline $"(ansi cyan_bold)($response.delta)(ansi reset)"
				$response.delta
			}
		}
	} | str join

	$history = ($history | append { role: "assistant", content: $assistant_message })

	$"\nAssistant:\n\n($assistant_message)\n" | save --append $env.log_file

    print $"\n"
}

