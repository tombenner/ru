require 'spec_helper'

describe Ru::Process do
  include FixturesHelper
  include ProcessHelper

  describe "#run" do
    it "runs []" do
      lines = %w{john paul george ringo}
      out = run('[1,2]', lines)
      expect(out).to eq("paul\ngeorge")
    end

    it "runs files" do
      paths = [
        fixture_path('files', 'bar.txt'),
        fixture_path('files', 'foo.txt')
      ]
      out = run('files', paths)
      expect(out).to eq("bar.txt\nfoo.txt")
    end

    it "runs format" do
      paths = [
        fixture_path('files', 'bar.txt'),
        fixture_path('files', 'foo.txt')
      ]
      out = run("files.format('l')", paths)
      lines = out.split("\n")
      expect(lines.length).to eq(2)
      lines.each do |line|
        # 644 tom staff 11  2014-11-04  08:29 foo.txt
        expect(line).to match(/^\d{3}\t\w+\t\w+\t\d+\t\d{4}\-\d{2}-\d{2}\t\d{2}:\d{2}\t[\w\.]+$/)
      end
    end

    it "runs grep" do
      lines = %w{john paul george ringo}
      out = run("grep(/o[h|r]/)", lines)
      expect(out).to eq("john\ngeorge")
    end

    it "runs map with two arguments" do
      lines = %w{john paul george ringo}
      out = run('map(:[], 0)', lines)
      expect(out).to eq(%w{j p g r}.join("\n"))
    end

    it "runs sort" do
      lines = %w{john paul george ringo}
      out = run('sort', lines)
      expect(out).to eq(lines.sort.join("\n"))
    end

    it "takes files as arguments" do
      out = run(['to_s', fixture_path('files', 'foo.txt')])
      expect(out).to eq("foo\nfoo\nfoo")
    end

    it "runs code prepended by '! '" do
      out = run('! 2 + 3')
      expect(out).to eq('5')
    end

    context "no arguments" do
      it "prints help" do
        allow(STDERR).to receive(:puts) do |out|
          expect(out).to include('Ruby in your shell!')
        end
        allow_any_instance_of(Ru::Process).to receive(:exit).with(1)
        run('')
      end
    end

    context "an undefined method" do
      it "raises a NoMethodError" do
        lines = %w{john paul george ringo}
        expect { out = run('foo', lines) }.to raise_error(NoMethodError)
      end
    end

    describe "command management" do
      describe "list" do
        it "lists the commands" do
          allow_any_instance_of(Ru::CommandManager).to receive(:get_commands).and_return({
            'product' => 'map(:to_i).reduce(:*)',
            'sum' => 'map(:to_i).sum',
          })
          out = run(['list'])
          expect(out).to eq("Saved commands:\nproduct\tmap(:to_i).reduce(:*)\nsum\tmap(:to_i).sum")
        end

        context "no saved commands" do
          it "shows a message" do
            allow_any_instance_of(Ru::CommandManager).to receive(:get_commands).and_return({})
            out = run(['list'])
            expect(out).to eq("No saved commands. To save a command, use `save`:\nru save sum 'map(:to_i).sum'")
          end
        end
      end

      describe "run" do
        it "runs the command" do
          allow_any_instance_of(Ru::CommandManager).to receive(:get_commands).and_return({ 'sum' => 'map(:to_i).sum' })
          out = run(['run', 'sum'], "2\n3")
          expect(out).to eq('5')
        end

        context "no command name" do
          it "raises an InvalidNameError" do
            expect { run(['run']) }.to raise_error(Ru::CommandManager::InvalidNameError)
          end
        end
      end

      describe "save" do
        it "saves the command" do
          allow_any_instance_of(Ru::CommandManager).to receive(:save_commands)
          run(['save', 'foo', 'map(:to_i).sum'])
        end

        context "no code" do
          it "raises an InvalidCodeError" do
            expect { run(['save', 'foo']) }.to raise_error(Ru::CommandManager::InvalidCodeError)
          end
        end

        context "invalid command name" do
          it "raises an InvalidNameError" do
            expect { run(['save', 'foo-bar', 'map(:to_i).sum']) }.to raise_error(Ru::CommandManager::InvalidNameError)
          end
        end
      end
    end

    describe "options" do
      context "-h" do
        it "shows help" do
          out = run('--help')
          expect(out).to include('Ruby in your shell!')
        end
      end

      context "--help" do
        it "shows help" do
          out = run('-h')
          expect(out).to include('Ruby in your shell!')
        end
      end

      context "help with a second argument" do
        it "shows help" do
          out = run(['--help', 'foo'])
          expect(out).to include('Ruby in your shell!')
        end
      end

      context "-v" do
        it "shows the version" do
          out = run('-v')
          expect(out).to eq(Ru::VERSION)
        end
      end

      context "--version" do
        it "shows the version" do
          out = run('--version')
          expect(out).to eq(Ru::VERSION)
        end
      end

      context "version with a second argument" do
        it "shows the version" do
          out = run(['--version', 'foo'])
          expect(out).to eq(Ru::VERSION)
        end
      end
    end
  end
end
