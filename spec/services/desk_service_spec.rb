require "spec_helper"

RSpec.describe DeskService do
  context 'can be created' do
    specify "with default gateway" do
      expect(DeskGateway).to receive(:new).and_return(:foo)
      expect(described_class.new.gateway).to eq(:foo)
    end

    specify "with specific gateway" do
      expect(DeskGateway).to_not receive(:new)
      expect(described_class.new(:bar).gateway).to eq(:bar)
    end
  end

  let(:gateway) { double('gateway') }
  subject { described_class.new(gateway) }

  let(:response) {
    {
      '_embedded' => {
        'entries' => entries
      }
    }
  }

  let(:entries) { [] }

  RSpec.shared_examples "a named collection fetcher" do

    def generate_entry(name, url, clazz)
      {
        'name' => name,
        '_links' => {
          'self' => {
            'href' => url,
            'class' => clazz
          }
        }
      }
    end

    before do
      allow(gateway).to receive(:fetch_records).with(url).and_return(response)
    end

    it 'delegates to gateway' do
      expect(gateway).to receive(:fetch_records).with(url).and_return(response)
      collection
    end

    context 'when response contains no collection' do
      it 'returns empty array' do
        expect(collection).to be_empty
      end
    end

    context 'when response contains 1 entry' do
      let(:entries) {
        [ generate_entry('foo', 'bar', clazz) ]
      }

      it 'returns entry object' do
        expect(collection.size).to eq(1)
        expect(collection.first.name).to eq('foo')
        expect(collection.first.url).to eq('bar')
      end
    end

    context 'when response contains 3 entries' do
      let(:entries) {
        [
          generate_entry('foo1', 'bar1', clazz),
          generate_entry('foo2', 'bar2', clazz),
          generate_entry('foo3', 'bar3', clazz)
        ]
      }

      it 'returns 3 entry objects' do
        expect(collection.size).to eq(3)
        expect(collection.first.name).to eq('foo1')
        expect(collection.last.url).to eq('bar3')
      end
    end

    context 'when response contains object of unexpected class' do
      let(:entries) {
        [ generate_entry('foo', 'bar', 'Toothless') ]
      }

      it 'raises an error' do
        expect { collection }.to raise_error
      end
    end
  end

  context '#fetch_filters' do
    let(:url) { '/api/v2/filters' }
    let(:collection) { subject.fetch_filters }
    let(:clazz) { 'filter' }

    it_behaves_like 'a named collection fetcher'
  end

  context '#fetch_labels' do
    let(:url) { '/api/v2/labels' }
    let(:collection) { subject.fetch_labels }
    let(:clazz) { 'label' }

    it_behaves_like 'a named collection fetcher'
  end

  describe '#fetch_filtered_cases' do
    let(:filter) { DeskService::Filter.new('foo', '/api/v2/filter/1') }
    let(:url) { '/api/v2/filter/1/cases' }
    let(:collection) { subject.fetch_filtered_cases(filter) }
    let(:clazz) { 'case' }

    def generate_entry(subj, labels, url, clazz)
      {
        'subject' => subj,
        'labels' => labels,
        '_links' => {
          'self' => {
            'href' => url,
            'class' => clazz
          }
        }
      }
    end

    before do
      allow(gateway).to receive(:fetch_records).with(url).and_return(response)
    end

    it 'delegates to gateway' do
      expect(gateway).to receive(:fetch_records).with(url).and_return(response)
      collection
    end

    context 'when response contains no collection' do
      it 'returns empty array' do
        expect(collection).to be_empty
      end
    end

    context 'when response contains 1 entry' do
      let(:entries) {
        [ generate_entry('foo', [], 'bar', clazz) ]
      }

      it 'returns entry object' do
        expect(collection.size).to eq(1)
        expect(collection.first.subject).to eq('foo')
        expect(collection.first.url).to eq('bar')
      end
    end

    context 'when response contains 3 entries' do
      let(:entries) {
        [
          generate_entry('foo1', [], 'bar1', clazz),
          generate_entry('foo2', [], 'bar2', clazz),
          generate_entry('foo3', [], 'bar3', clazz)
        ]
      }

      it 'returns 3 entry objects' do
        expect(collection.size).to eq(3)
        expect(collection.first.subject).to eq('foo1')
        expect(collection.last.url).to eq('bar3')
      end
    end

    context 'when response contains object of unexpected class' do
      let(:entries) {
        [ generate_entry('foo', [], 'bar', 'Toothless') ]
      }

      it 'raises an error' do
        expect { collection }.to raise_error
      end
    end

    context 'when response contains entry with labels' do
      let(:entries) {
        [ generate_entry('foo', ['l1', 'l2'], 'bar', clazz) ]
      }

      it 'returns entry object with labels' do
        expect(collection.size).to eq(1)
        expect(collection.first.labels).to eq(['l1', 'l2'])
      end
    end
  end

  describe '#create_label' do
    let(:url) { '/api/v2/labels' }
    let(:clazz) { 'label' }
    let(:name) { 'foo' }

    let(:response) {
      {
        'name' => name,
        '_links' => {
          'self' => {
            'href' => 'bar',
            'class' => clazz
          }
        }
      }
    }

    before do
      allow(gateway).to receive(:post_data).with(url, name: name).and_return(response)
    end

    it 'delegates to gateway' do
      expect(gateway).to receive(:post_data).with(url, name: name).and_return(response)
      subject.create_label(name)
    end

    context 'when response contains label' do
      it 'returns label object' do
        label = subject.create_label(name)
        expect(label.name).to eq(name)
        expect(label.url).to eq('bar')
      end
    end

    context 'when response contains object of unexpected class' do
      let(:clazz) { 'Toothless' }

      it 'raises an error' do
        expect { subject.create_label(name) }.to raise_error
      end
    end
  end

  describe '#assign_label' do
    let(:url) { 'bar' }
    let(:label) { double('label', name: 'l1') }
    let(:a_case) { double('case', url: url) }
    let(:clazz) { 'case' }

    let(:response) {
      {
        'subject' => 'foo',
        'labels' => ['l1'],
        '_links' => {
          'self' => {
            'href' => 'bar',
            'class' => clazz
          }
        }
      }
    }

    before do
      allow(gateway).to receive(:patch_data).with(url, anything).and_return(response)
    end

    it 'delegates to gateway' do
      expect(gateway).to receive(:patch_data).with(url, label_action: 'append', labels: [label.name]).and_return(response)
      subject.assign_label(label, a_case)
    end

    context 'when response contains case' do
      it 'returns case object' do
        updated_case = subject.assign_label(label, a_case)
        expect(updated_case.subject).to eq('foo')
        expect(updated_case.labels).to eq(['l1'])
      end
    end
  end
end
