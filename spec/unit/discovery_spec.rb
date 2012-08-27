require 'spec_helper'

describe TentClient::Discovery do
  LINK_HEADER = %Q(<https://example.com/tent/profile>; rel="profile"; type="%s") % TentClient::PROFILE_MEDIA_TYPE
  LINK_TAG_HTML = %Q(<html><head><link href="https://example.com/tent/profile" rel="profile" type="%s" /></head</html>) % TentClient::PROFILE_MEDIA_TYPE

  let(:http_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) { TentClient.new(nil, :faraday_adapter => [:test, http_stubs]) }

  it 'should discover profile urls via a link header' do
    http_stubs.head('/') { [200, { 'Link' => LINK_HEADER }, ''] }

    discovery = described_class.new(client, 'http://example.com/')
    discovery.perform.should eq(['https://example.com/tent/profile'])
  end

  it 'should discover profile urls via a link html tag' do
    http_stubs.head('/') { [200, { 'Content-Type' => 'text/html' }, ''] }
    http_stubs.get('/') { [200, { 'Content-Type' => 'text/html' }, LINK_TAG_HTML] }

    discovery = described_class.new(client, 'http://example.com/')
    discovery.perform.should eq(['https://example.com/tent/profile'])
  end

  it 'should work with relative urls' do
    http_stubs.head('/') { [200, { 'Link' => LINK_HEADER.sub(%r{https://example.com}, '') }, ''] }

    discovery = described_class.new(client, 'http://example.com/')
    discovery.perform.should eq(['http://example.com/tent/profile'])
  end

  it 'should delegate TentClient.discover' do
    instance = stub(:perform => 1)
    described_class.expects(:new).with(client, 'url').returns(instance)
    client.discover('url').should eq(1)
  end
end