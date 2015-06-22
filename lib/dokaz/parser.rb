# encoding: utf-8
require 'strscan'
require 'stringio'

class Dokaz
  class Statement
    attr_reader :code, :line, :block

    def initialize(code, line, block)
      @raw_code, @line, @block = code, line, block
      make_code!
    end

    def empty?
      code.empty?
    end

    def make_code!
      lines = @raw_code.split("\n")
      while !lines.empty? && (lines.first =~ /^\s*\#/ || lines.first.strip.empty?)
        lines.shift
        @line += 1
      end
      @code = lines.join("\n")
    end
  end
  
  class Block
    attr_reader :code, :line, :file
    attr_reader :statements

    def initialize(code, line, file)
      @code, @line, @file = code, line, file

      parse_statements!
    end

    def end_line
      line + code.count("\n")
    end
    
    def caption
      "#{file}:#{line}"
    end

    def inside?(ln)
      (line..end_line).cover?(ln)
    end

    private

      def parse_statements!
        @statements = []
        lex = RubyLex.new
        lex.set_input(SpecIO.new(code))
        lex.each_top_level_statement do |st, line_no|
          @statements << Statement.new(st, line + line_no, self)
        end
        @statements.reject!(&:empty?)
      end
  end
  
  class Parser
    def initialize(path)
      @path = path
    end

    def parse
      res = []
      ln = 0
      scanner = StringScanner.new(File.read(@path))
      loop do
        text = scanner.scan_until(/\n```ruby\n/)
        break unless text
        
        ln += text.count("\n")
        code = scanner.scan_until(/\n```\n/)
        if !code
          res << Block.new(scanner.rest, ln, @path)
          break
        end
        res << Block.new(code.sub(/```\Z/, ''), ln, @path)
        ln += code.count("\n")
      end

      res
    end
  end
end
