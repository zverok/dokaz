# encoding: utf-8
require 'strscan'
require 'stringio'

class Dokaz
  class Statement
    attr_reader :code, :line, :block
    attr_reader :pre_comment
    attr_accessor :comment

    def initialize(code, line, block)
      @raw_code, @line, @block = code, line, block
      @comment = ''
      
      parse!
    end

    def empty?
      code.empty?
    end

    private

    def parse!
      pre_lines = []
      lines = @raw_code.split("\n")
      while !lines.empty? && (lines.first =~ /^\s*\#/ || lines.first.strip.empty?)
        pre_lines << lines.shift
        @line += 1
      end
      @code = lines.join("\n")
      @pre_comment = pre_lines.reject{|ln| ln.strip.empty?}.join("\n")
    end
  end
  
  class Block
    FakeIRBContext = Struct.new(:local_variables)

    attr_reader :code, :line, :file
    attr_reader :statements

    def initialize(code, line, file)
      @code, @line, @file = code, line, file

      parse!
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

    def parse!
      @statements = []
      lex = RubyLex.new

      # We do unholy things by reusing IRB's internal helper classes.
      # In 3.2 (ver.1.6), IRB changed them to be more complicated. I only had
      # time to quick-hack it around with fake copies of object IRB use.
      # It might fail anytime, but works on test examples :shrug:
      if IRB::VERSION >= '1.6'
        ctx = FakeIRBContext.new(local_variables: [])
        lex.set_input(SpecIO.new(code), context: ctx)
        lex.each_top_level_statement(ctx) do |st, line_no|
          @statements << Statement.new(st, line + line_no, self)
        end
      else
        lex.set_input(SpecIO.new(code))
        lex.each_top_level_statement do |st, line_no|
          @statements << Statement.new(st, line + line_no, self)
        end
      end

      @statements.each_cons(2){|s1, s2|
        s1.comment = s2.pre_comment
      }
      @statements.reject!(&:empty?)
    end
  end
  
  class Parser
    def initialize(path)
      @path = path
    end

    def parse
      blocks = []
      ln = 0
      
      scanner = StringScanner.new(File.read(@path))

      loop do
        text = scanner.scan_until(/\n```ruby\n/)
        break unless text
        
        ln += text.count("\n")
        code = scanner.scan_until(/\n```\n/)
        if !code
          blocks << Block.new(scanner.rest, ln, @path)
          break
        end
        blocks << Block.new(code.sub(/```\Z/, ''), ln, @path)
        ln += code.count("\n")
      end

      blocks
    end
  end
end
