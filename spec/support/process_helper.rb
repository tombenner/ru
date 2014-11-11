module ProcessHelper
  def run(stdin, *args)
    if stdin.kind_of?(Array)
      stdin = stdin.join("\n")
    end
    command = args.shift
    process = Ru::Process.new({
      command: command,
      args: args,
      stdin: stdin
    })
    process.run
  end
end