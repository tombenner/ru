module ProcessHelper
  def run(args, stdin=nil)
    if args.kind_of?(String)
      args = [args]
    end
    stub_const('ARGV', args)

    if stdin.kind_of?(Array)
      stdin = stdin.join("\n")
    end
    if stdin
      stdin_double = double
      allow(stdin_double).to receive(:read).and_return(stdin)
      allow(stdin_double).to receive(:each_line).and_return(stdin.each_line)
      allow(stdin_double).to receive(:each_byte).and_return(stdin.each_byte)
      stub_const('STDIN', stdin_double)
    end

    process = Ru::Process.new
    process.run
  end

  def run_stream(args, stdin=nil)
    if args.kind_of?(String)
      args = [args]
    end
    args.unshift ['-s', '--stream'].sample
    run args, stdin
  end
end
