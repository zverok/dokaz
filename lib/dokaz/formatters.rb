# encoding: utf-8
require 'ansi/code'

class Dokaz
  class Formatter
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

      @errors.each do |code, e|
        puts code
        puts( error("#{e.message} (#{e.class})\n  " + filter_backtrace(e.backtrace).join("\n  ") + "\n"))
      end

      puts
      @errors.each do |code, e|
        ln = e.backtrace.first.sub(/:in .*$/, '')
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
    
    def output(code, res, out)
      puts code
      unless out.empty?
        puts comment("# Prints: \n#  " + out.split("\n").join("\n#    "))
      end
      puts comment("# => " + res.inspect.split("\n").join("\n#    "))
    end

    def output_err(code, e)
      puts code
      puts comment("# Throws: #{e.message} (#{e.class})")
    end

    def finish_block(block)
      puts "\n\n"
    end
  end
end
