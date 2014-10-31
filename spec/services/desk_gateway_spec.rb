require "spec_helper"

RSpec.describe DeskGateway do
  let(:stubs) {
    Faraday::Adapter::Test::Stubs.new
  }

  before do
    allow(subject).to receive(:faraday_stubs).and_return(stubs)
  end

  describe '#fetch_records' do
    it 'returns parsed JSON found in response body' do
      stubs.get("/foo") {[ 200, {}, '{ "foo": "bar" }' ]}

      expect(subject.fetch_records('/foo')).to eq({'foo' => 'bar'})
    end

    it "raises error if non-OK response is returned" do
      stubs.get("/foo") {[ 400, {}, '' ]}

      expect {
        subject.fetch_records('/foo')
      }.to raise_error Faraday::ClientError
    end
  end

  describe '#post_data' do
    it 'returns parsed JSON found in response body' do
      stubs.post("/foo") {[ 200, {}, '{ "foo": "bar" }' ]}

      expect(subject.post_data('/foo', {})).to eq({'foo' => 'bar'})
    end

    it 'includes proper JSON in post request' do
      stubs.post("/foo", '{"a":"b"}') {[ 200, {}, '' ]}

      expect(subject.post_data('/foo', a: 'b'))
    end

    it "raises error if non-OK response is returned" do
      stubs.post("/foo") {[ 400, {}, '' ]}

      expect {
        subject.post_data('/foo', a: 'b')
      }.to raise_error Faraday::ClientError
    end
  end

  describe '#patch_data' do
    it 'returns parsed JSON found in response body' do
      stubs.patch("/foo") {[ 200, {}, '{ "foo": "bar" }' ]}

      expect(subject.patch_data('/foo', {})).to eq({'foo' => 'bar'})
    end

    it 'includes proper JSON in patch request' do
      stubs.patch("/foo", '{"a":"b"}') {[ 200, {}, '' ]}

      expect(subject.patch_data('/foo', a: 'b'))
    end

    it "raises error if non-OK response is returned" do
      stubs.patch("/foo") {[ 400, {}, '' ]}

      expect {
        subject.patch_data('/foo', a: 'b')
      }.to raise_error Faraday::ClientError
    end
  end
end
