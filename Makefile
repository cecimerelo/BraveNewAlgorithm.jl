all: instantiate tests

instantiate: Project.toml
	julia --project=. -e "using Pkg; Pkg.instantiate()"

tests: instantiate
	julia --project=. test/runtests.jl

precompile:
	julia --startup-file=no --project=. sysimage/build_bbob_sysimage.jl
