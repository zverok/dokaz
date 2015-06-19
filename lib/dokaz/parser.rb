# encoding: utf-8
require 'strscan'

class Dokaz
  class Block
    attr_reader :code, :line, :file
    def initialize(code, line, file)
      @code, @line, @file = code, line, file
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
