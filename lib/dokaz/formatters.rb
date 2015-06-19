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
        print ANSI.green{'.'}
      end
    end

    def finalize
      puts
      puts

      @errors.each do |code, e|
        puts code
        puts( ANSI.red{"#{e.message} (#{e.class})\n  " + filter_backtrace(e.backtrace).join("\n  ") + "\n"})
      end

      puts
      puts [
        "#{@ok + @errors.count} total",
        !@ok.zero? && ANSI.green{"#{@ok} ok"},
        !@errors.empty? && ANSI.red{"#{@errors.count} errors"}
      ].select{|l| l}.join(', ')
      
    end
    
    def output_err(code, e)
      @errors << [code, e]
      print ANSI.red{'F'}
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
      puts comment("# Throws: #{e.message} #{e.class}\n#    " + filter_backtrace(e.backtrace).join("\n#    "))
    end

    def finish_block(block)
      puts "\n\n"
    end

    private
      def comment(str)
        ANSI.dark{str}
      end
  end
end
