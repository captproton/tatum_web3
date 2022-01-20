# frozen_string_literal: true

RSpec.describe TatumWeb3 do

  ROUTES = TatumWeb3.routes
  it "has a version number" do
    expect(TatumWeb3::VERSION).not_to be nil
  end

  describe "connection" do
    subject = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']})

    it "has a query param" do
    expect(subject.query.class).to be Hash
    end
    
    it "has a header param" do
    expect(subject.query.class).to be Hash
    end

    it "headers has an api key " do
      expect(subject.headers["x-api-key"].to_s.length).to be > 10 
    end
    
    # it "get " do
      
    # end
    
    
  end

  describe "Client" do
    # wallet = client.generate_flow_wallet
    connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']})

    subject   = TatumWeb3::Client.new(connection: connection, routes: ROUTES)
    

    describe "can create a wallet" do
      response = subject.generate_flow_wallet
      
      it "has a response key of mnemonic" do
        expect(response.keys).to include "mnemonic"         
      end
      it "has a response key of mnemonic with a length of 24 words" do
        expect(response["mnemonic"].split(" ").length).to be 24         
      end

      it "has a response key of xpub" do
        expect(response.keys).to include "xpub"         
      end
      it "has a response key xpub with a length of more than 100" do
        expect(response["xpub"].length).to be  > 100        
      end

    end
    
  end
  
          # expect(response.keys).to include "something"         

    
end
