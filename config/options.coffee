mock        = false

# parse args
exports.parse = (argv) ->
  argv.forEach (val, index, params) ->
    mock = true if /\-\-mock|\-m/.test(val) 
  return mock: mock