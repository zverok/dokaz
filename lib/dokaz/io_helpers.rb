# encoding: utf-8
class Dokaz
  class SpecIO < StringIO
    def encoding
      string.encoding
    end
  end

  class Out < StringIO
    def capture(&block)
      orig = $stdout
      $stdout = self
      yield
      string.to_s
    ensure
      $stdout = orig
    end
  end
end
