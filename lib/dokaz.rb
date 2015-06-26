# encoding: utf-8
require 'irb'

require_relative 'dokaz/parser'
require_relative 'dokaz/io_helpers'
require_relative 'dokaz/formatters'

class Dokaz
  FORMATTERS = {
    'spec' => SpecFormatter,
    'show' => ShowcaseFormatter,
    'showcase' => ShowcaseFormatter
  }

  class << self
    def before(&block)
      return @before || ->(){} unless block
      @before = block
    end
  end
  
  def initialize(patterns, options = {})
    @blocks = select_blocks(patterns)

    if options[:require]
      options[:require].split(',').each{|f| require f}
    end

    @formatter = FORMATTERS[options[:format] || 'spec'].new
  end

  def run
    self.class.before.call
    
    puts "Running #{@blocks.count} blocks from #{@blocks.map(&:file).uniq.count} files\n\n"
    
    @blocks.each do |b|
      @formatter.start_block(b)
      process_block(b)
      @formatter.finish_block(b)
    end
    @formatter.finalize
  end

  private

    def process_block(block)
      block.statements.each do |st|
        begin
          res = nil
          out = capture_output{
            res = eval(st.code, TOPLEVEL_BINDING, block.file, st.line)
          }
          @formatter.output(st.code, res, out)
        rescue => e
          @formatter.output_err(st.code, e)
          break
        end
      end
    end

    def capture_output(&block)
      Out.new.capture(&block)
    end

    def select_blocks(patterns)
      patterns.map{|pat|
        path, ln = pat.split(':', 2)
        files = Dir[path]
        blocks = files.map{|f|
          Parser.new(f).parse
        }.flatten.select{|b|
          ln ? b.inside?(ln.to_i) : true
        }
      }.flatten
    end
end
