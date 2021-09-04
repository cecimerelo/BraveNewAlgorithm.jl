all: check_dependencies tests

check_dependencies: Project.toml requirements.jl
	julia --project=Project.toml requirements.jl  --target=Project.toml

tests: check_dependencies
	julia --project=. test/runtests.jl