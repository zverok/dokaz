# encoding: utf-8
class Dokaz
  describe Parser do
    let(:path){'spec/fixtures/Sample.md'}
    let(:blocks){described_class.new(path).parse}
    
    describe 'file -> blocks' do
      subject{blocks}

      it{should be_kind_of(Array)}
      it{should all(be_kind_of(Block))}
      its(:count){should == 3}

      it 'should set file and line correctly' do
        expect(subject[0].code).to include('first')
        expect(subject[0].line).to eq 9
        expect(subject[0].end_line).to eq 17
        expect(subject[0].file).to eq path

        expect(subject[1].code).to include('second')
        expect(subject[1].line).to eq 21
        expect(subject[1].end_line).to eq 29
        expect(subject[1].file).to eq path

        expect(subject[2].code).to include('third')
        expect(subject[2].line).to eq 33
        expect(subject[2].end_line).to eq 34
        expect(subject[2].file).to eq path
      end

      it 'ignores everything between disable/enable comments' do
      end
    end

    describe 'block -> statements' do
      subject{blocks[1]}
      its(:'statements.count'){should == 2}
      its(:'statements.first.code'){
        should include('puts "WTF??? I just typed ```"')
      }
      its(:'statements.first.comment'){should == '# this comment goes to first statement!'}
      its(:'statements.last.comment'){should == '# and this for second'}
    end
  end
end
