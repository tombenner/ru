module ProcessHelper
  def run(args, stdin=nil)
    if args.kind_of?(String)
      args = [args]
    end
    stub_const('ARGV', args)

    if stdin.kind_of?(Array)
      stdin = stdin.join("\n")
    end
    stdin_double = double
    stdin_double.stub(:read).and_return(stdin)
    stub_const('STDIN', stdin_double)

    process = Ru::Process.new
    process.run
  end
end