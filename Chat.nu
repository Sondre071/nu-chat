const project_dir = path self | path dirname
const logs_dir = $project_dir | path join '.user' 'logs'

$env.api_key = open --raw $"($project_dir)/.user/api-key"
$env.model = 'anthropic/claude-sonnet-4.5'
$env.log_file = $logs_dir | path join (
    date now | format date "%Y-%m-%d_%H-%M-%S"
)

if not ($logs_dir | path exists) {
    mkdir $logs_dir
}

if not ($env.log_file | path exists) {
    touch $env.log_file
}

source lib/run-chat.nu

