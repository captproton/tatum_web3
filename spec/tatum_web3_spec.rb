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

  describe "supports #_assemble_route" do
    routes    = TatumWeb3.routes

    # accounts
    it "supports creating a route without path_vars" do
      route = routes["generate_flow_wallet"]
      subject   = TatumWeb3._assemble_route(route: route, path_vars: {})
      expect(subject).to eq("/flow/wallet/")
    end

    describe "supports creating a route with path_vars" do
      # path: "/flow/address/:xpub/:index"
      route = routes["generate_flow_account_address_from_extended_public_key"]
      subject   = TatumWeb3._assemble_route(route: route, path_vars: {xpub:"thankyou", index:"1"})

      it "supports creating a route with path_vars" do
        expect(subject).to eq("/flow/address/thankyou/1")
      end

      it "assigns first path_var to the proper place in the relative_path" do
        xpub = subject.split("/")[3]
        expect(xpub).to  eq("thankyou")
      end
      
      it "assigns second path_var to the proper place in the relative_path" do
        index = subject.split("/")[4]
        expect(index).to  eq("1")
      end

    end
  end

  describe "Client" do
    # wallet = client.generate_flow_wallet
    connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']})

    subject   = TatumWeb3::Client.new(connection: connection, routes: TatumWeb3.routes)
    

    describe "supports account calls" do
      # describe "can generate a wallet" do
      #   response = subject.generate_flow_wallet
        
      #   it "has a response key of mnemonic" do
      #     expect(response.keys).to include "mnemonic"         
      #   end
      #   it "has a response key of mnemonic with a length of 24 words" do
      #     expect(response["mnemonic"].split(" ").length).to be 24         
      #   end

      #   it "has a response key of xpub" do
      #     expect(response.keys).to include "xpub"         
      #   end
      #   it "has a response key xpub with a length of more than 100" do
      #     expect(response["xpub"].length).to be  > 100        
      #   end

      # end
      
    
      # deploy_flow_nft

      # it "supports deploying a flow nft" do
      #   route = ROUTES["deploy_flow_nft"]
      #   subject   = TatumWeb3._assemble_route(route: route, path_vars: {})
      #   # expect(TatumWeb3._assemble_route(relative_path, )).to eq("/flow/wallet")
      #   expect(subject).to eq("/flow/wallet/")
      # end


    end

    describe "supports interacting with the blockchain" do
      it "supports getting the current block number" do
        
      end

      it "supports getting block by hash" do
        
      end

      it "supports sending  Flow/FUSD from one account to another" do
        
      end

      it "supports getting a transaction" do
        
      end
      
      it "supports sending a custom transaction" do
        
      end
        
    end

    describe "supports interacting with NFT's" do
      
    end

    describe "supports interacting with IPFS" do
      
    end
  end
  
end
