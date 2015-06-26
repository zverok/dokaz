# encoding: utf-8
require 'ansi/code'
require 'rouge'

class Dokaz
  class Formatter
    def initialize
      @rouge = Rouge::Formatters::Terminal256.new(theme: 'molokai')
      @lexer = Rouge::Lexers::Ruby.new
    end
    
    def start_block(block)
    end

    def finish_block(block)
    end

    def finalize
    end

    def output(code, res, out)
    end
    
    def output_err(code, e)
    end

    protected
      def filter_backtrace(trace)
        trace.take_while{|ln| ln !~ /lib\/dokaz/}
      end

      def ok(str)
        color(:green, str)
      end

      def error(str)
        color(:red, str)
      end

      def comment(str)
        color(:dark, str)
      end

      def code(str)
        if STDOUT.tty?
          @rouge.format(@lexer.lex(str))
        else
          code
        end
      end

      def color(code, str)
        if STDOUT.tty?
          ANSI.send(code){str}
        else
          str
        end
      end
  end
  
  class SpecFormatter < Formatter
    def initialize
      super
      @ok = 0
      @errors = []
    end
    
    def start_block(block)
      @err = false
    end

    def finish_block(block)
      unless @err
        @ok += 1 
        print ok('.')
      end
    end

    def finalize
      puts
      puts

      @errors.each do |src, e|
        puts code(src)
        puts( error("#{e.message} (#{e.class})\n  " + filter_backtrace(e.backtrace).join("\n  ") + "\n"))
      end

      puts
      @errors.each do |code, e|
        ln = filter_backtrace(e.backtrace).last.sub(/:in .*$/, '')
        puts error("dokaz #{ln}") + comment(" # #{e.message} (#{e.class})")
      end

      puts
      puts [
        "#{@ok + @errors.count} total",
        !@ok.zero? && ok("#{@ok} ok"),
        !@errors.empty? && error("#{@errors.count} errors")
      ].select{|l| l}.join(', ')
      
    end
    
    def output_err(code, e)
      @errors << [code, e]
      print error('F')
      @err = true
    end
  end

  class ShowcaseFormatter < Formatter
    def start_block(block)
      puts "#{block.caption}\n#{'=' * block.caption.size}\n\n"
    end
    
    def output(src, res, out)
      puts code(src)
      unless out.empty?
        puts comment("# Prints: \n#  " + out.split("\n").join("\n#  "))
      end
      puts comment("# => " + res.inspect.split("\n").join("\n#    "))
    end

    def output_err(src, e)
      puts code(src)
      puts comment("# Throws: #{e.message} (#{e.class})")
    end

    def finish_block(block)
      puts "\n\n"
    end
  end
end
