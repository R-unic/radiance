require "optparse"
require "readline"
require_relative "runtime/interpreter"

def lang_name
  "test-lang"
end

class CLI
  @@interpreter = Interpreter.new

  class << self
    def read_source(source, repl = false)
      @@interpreter.interpret(source, repl)
    end

    def read_file(path)
      File.read(path)
    rescue StandardError => e
      $stderr.puts "Failed to read file \"#{path}\": #{e}"
      exit(1)
    end

    def run_repl
      puts "Welcome to the #{lang_name} REPL"
      loop do
        line = Readline.readline("➤ ", true)
        break if line.nil?
        read_source(line, true)
      end
    end

    def run
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #{lang_name} [options] [file_path]"
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end.parse!(into: options)

      if ARGV.empty?
        run_repl
      else
        path = ARGV[0]
        file_contents = read_file(path)
        read_source(file_contents)
      end
    end
  end
end
