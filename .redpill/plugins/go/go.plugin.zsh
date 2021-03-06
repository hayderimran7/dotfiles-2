# install in /etc/zsh/zshrc or your personal .zshrc

# gc
prefixes=(5 6 8)
for p in $prefixes; do
	compctl -g "*.${p}" ${p}l
	compctl -g "*.go" ${p}g
done
unset p

# standard go tools
compctl -g "*.go" gofmt

# gccgo
compctl -g "*.go" gccgo

# go tool
__go_tool_complete()
{
  typeset -a commands build_flags

  commands+=(
    'build[compile packages and dependencies]'
    'clean[remove object files]'
    'doc[run godoc on package sources]'
    'env[print Go environment information]'
    'fix[run go tool fix on packages]'
    'fmt[run gofmt on package sources]'
    'get[download and install packages and dependencies]'
    'help[display help]'
    'install[compile and install packages and dependencies]'
    'list[list packages]'
    'run[compile and run Go program]'
    'test[test packages]'
    'tool[run specified go tool]'
    'version[print Go version]'
    'vet[run go tool vet on packages]'
  )

  if (( CURRENT == 2 )); then
    # explain go commands
    _values 'go tool commands' ${commands[@]}
    return
  fi

  build_flags=(
    '-a[force reinstallation of packages that are already up-to-date]'
    '-n[print the commands but do not run them]'
    '-p[number of parallel builds]:number'
    '-race[enable data race detection]'
    '-x[print the commands]'
    '-work[print temporary directory name and keep it]'
    '-ccflags[flags for 5c/6c/8c]:flags'
    '-gcflags[flags for 5g/6g/8g]:flags'
    '-ldflags[flags for 5l/6l/8l]:flags'
    '-gccgoflags[flags for gccgo]:flags'
    '-compiler[name of compiler to use]:name'
    '-installsuffix[suffix to add to package directory]:suffix'
    '-tags[list of build tags to consider satisfied]:tags'
  )

  __go_list()
  {
    local expl importpaths
    declare -a importpaths
    importpaths=($(go list ${words[$CURRENT]}... 2>/dev/null))
    _wanted importpaths expl 'import paths' compadd "$@" - "${importpaths[@]}"
  }

  case ${words[2]} in
    clean|doc)
      _arguments -s -w : '*:importpaths:__go_list'
    ;;
    fix|fmt|list|vet)
      _alternative ':importpaths:__go_list' ':files:_path_files -g "*.go"'
    ;;
    install)
      _arguments -s -w : ${build_flags[@]} \
        "-v[show package names]" \
        '*:importpaths:__go_list'
    ;;
    get)
      _arguments -s -w : \
        ${build_flags[@]}
    ;;
    build)
      _arguments -s -w : \
        ${build_flags[@]} \
        "-v[show package names]" \
        "-o[output file]:file:_files" \
        "*:args:{ _alternative ':importpaths:__go_list' ':files:_path_files -g \"*.go\"' }"
    ;;
    test)
      _arguments -s -w : \
        ${build_flags[@]} \
        "-c[do not run, compile the test binary]" \
        "-i[do not run, install dependencies]" \
        "-v[print test output]" \
        "-x[print the commands]" \
        "-short[use short mode]" \
        "-parallel[number of parallel tests]:number" \
        "-cpu[values of GOMAXPROCS to use]:number list" \
        "-run[run tests and examples matching regexp]:regexp" \
        "-bench[run benchmarks matching regexp]:regexp" \
        "-benchmem[print memory allocation stats]" \
        "-benchtime[run each benchmark until taking this long]:duration" \
        "-blockprofile[write goroutine blocking profile to file]:file" \
        "-blockprofilerate[set sampling rate of goroutine blocking profile]:number" \
        "-timeout[kill test after that duration]:duration" \
        "-cpuprofile[write CPU profile to file]:file:_files" \
        "-memprofile[write heap profile to file]:file:_files" \
        "-memprofilerate[set heap profiling rate]:number" \
        "*:args:{ _alternative ':importpaths:__go_list' ':files:_path_files -g \"*.go\"' }"
    ;;
    help)
      _values "${commands[@]}" \
        'gopath[GOPATH environment variable]' \
        'packages[description of package lists]' \
        'remote[remote import path syntax]' \
        'testflag[description of testing flags]' \
        'testfunc[description of testing functions]'
    ;;
    run)
      _arguments -s -w : \
          ${build_flags[@]} \
          '*:file:_path_files -g "*.go"'
    ;;
    tool)
      if (( CURRENT == 3 )); then
        _values "go tool" $(go tool)
        return
      fi
      case ${words[3]} in
      [568]g)
        _arguments -s -w : \
          '-I[search for packages in DIR]:includes:_path_files -/' \
          '-L[show full path in file:line prints]' \
          '-S[print the assembly language]' \
          '-V[print the compiler version]' \
          '-e[no limit on number of errors printed]' \
          '-h[panic on an error]' \
          '-l[disable inlining]' \
          '-m[print optimization decisions]' \
          '-o[file specify output file]:file' \
          '-p[assumed import path for this code]:importpath' \
          '-u[disable package unsafe]' \
          "*:file:_files -g '*.go'"
      ;;
      [568]l)
        local O=${words[3]%l}
        _arguments -s -w : \
          '-o[file specify output file]:file' \
          '-L[search for packages in DIR]:includes:_path_files -/' \
          "*:file:_files -g '*.[ao$O]'"
      ;;
      dist)
        _values "dist tool" banner bootstrap clean env install version
      ;;
      *)
        # use files by default
        _files
      ;;
    esac
    ;;
  esac
}

compdef __go_tool_complete go

# aliases
alias gfa='go fmt . ./...'

