# encoding: utf-8
class Dokaz
  describe Block do
    subject{described_class.new(source, 10, 'test.rb')}
    
    context 'parsing in statements' do
      let(:source){%Q{puts 1 + 15

class A
  def test
  end
end
      }}
      its(:'statements.count'){should == 2}
      its(:'statements.first.code'){should == 'puts 1 + 15'}
      its(:'statements.first.line'){should == 11}
    end

    context 'no comments to interpreter' do
      let(:source){%Q{# this is comment, but it is ignored!
puts 1 + 15

# and this is ignored too!
puts "yep"
      }}
      its(:'statements.count'){should == 2}
      its(:'statements.first.code'){should == 'puts 1 + 15'}
      its(:'statements.first.line'){should == 12}

      its(:'statements.last.code'){should == 'puts "yep"'}
    end

    context 'post-comment' do
      it 'extracts comments IMMEDIATELY AFTER block and use them as documentation'
    end
  end
end
