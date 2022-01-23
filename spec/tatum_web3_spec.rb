# frozen_string_literal: true

RSpec.describe TatumWeb3 do

  ROUTES = TatumWeb3.routes
  it "has a version number" do
    expect(TatumWeb3::VERSION).not_to be nil
  end

  describe "connection" do
    subject = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, path_vars: {xpub:"thankyou", index:"1"})

    it "has a query param" do
      expect(subject.query.class).to be Hash
    end
    
    it "has a headers param" do
      expect(subject.headers.class).to be Hash
    end

    it "has a path_vars param" do
      expect(subject.path_vars.class).to be Hash
    end

    it "headers has an api key " do
      expect(subject.headers["x-api-key"].to_s.length).to be > 10 
    end
    
    describe "#_assemble_route" do

      # accounts
      it "supports creating a relative_path without path_vars" do
        relative_path = "/flow/wallet"
        item   = TatumWeb3::Connection.new._assemble_path(relative_path: relative_path, path_vars: {})
        expect(item).to eq("/v3/flow/wallet/")
        # expect(item).to eq("something")
      end

      describe "supports creating a relative_path with path_vars" do
        # path: "/flow/address/:xpub/:index"
        relative_path = "/flow/address"
        item   = TatumWeb3::Connection.new._assemble_path(relative_path: relative_path, path_vars: {xpub:"thankyou", index:"1"})

        it "supports creating a route with path_vars" do
          expect(item).to eq("/v3/flow/address/thankyou/1")
        end

        it "assigns first path_var to the proper place in the relative_path" do
          xpub = item.split("/")[4]
          expect(xpub).to  eq("thankyou")
        end
        
        it "assigns second path_var to the proper place in the relative_path" do
          index = item.split("/")[5]
          expect(index).to  eq("1")
        end

      end
    end
    
    
  end


  describe "Client" do
    

    describe "account calls" do
      # wallet_connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, path_vars: {})
      # client   = TatumWeb3::Client.new(connection: wallet_connection, routes: TatumWeb3.routes)
      # wallet = client.generate_flow_wallet

      describe "can generate a wallet" do
        # wallet = client.generate_flow_wallet
        connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, path_vars: {})
        client   = TatumWeb3::Client.new(connection: connection, routes: TatumWeb3.routes)
        response = client.generate_flow_wallet
        
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
      
      describe "can create a new address on chain" do
        wallet_connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, 
                            path_vars: {}
                          )
        wallet_client   = TatumWeb3::Client.new(connection: wallet_connection, routes: TatumWeb3.routes)
        wallet = wallet_client.generate_flow_wallet

        connection  = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, 
                      path_vars: {xpub: wallet.fetch("xpub"), index:"1"}
                    )
        client      = TatumWeb3::Client.new(connection: connection, routes: TatumWeb3.routes)
        response    = client.generate_flow_account_address_from_extended_public_key
        subject     = response.parsed_response
        
        # it "has the proper path_vars for a connection" do
        #   expect(connection.path_vars).to  eq("something")
        # end
        
        it "is returns a key of account" do
          expect(response.parsed_response.keys.first).to eq("address") 
        end

        it "is returns an address value of length" do
          expect(subject.fetch("address").length).to be > 6
        end

        it "starts with" do
          expect(subject.fetch("address")).to include("0x")
        end
        
        
      end

      describe "can generate a private key" do
        wallet_connection = TatumWeb3::Connection.new(headers:{"x-api-key"=> ENV['TATUM_API_KEY']}, 
                            path_vars: {}
                          )
        wallet_client   = TatumWeb3::Client.new(connection: wallet_connection, routes: TatumWeb3.routes)
        wallet = wallet_client.generate_flow_wallet
#       @result     = HTTParty.post("http://127.0.0.1:8082/api/publish", :headers => {'Content-Type'=>'application/json'}, :body => params_hash.to_json,)
        connection  = TatumWeb3::Connection.new(
                      headers:  {'Content-Type'=>'application/json', "x-api-key"=> ENV['TATUM_API_KEY']}, 
                      body:     {index:0, "mnemonic":wallet.fetch("mnemonic")},
                      query:    {}

                    )
        client      = TatumWeb3::Client.new(connection: connection, routes: TatumWeb3.routes)
        response    = client.generate_private_key
        subject     = response.parsed_response
        
        it "with a wallet that has a response key of mnemonic" do
          expect(wallet.keys).to include "mnemonic"         
        end
        
        it "with a wallet that has a response key of mnemonic with a length of 24 words" do
          expect(wallet.fetch("mnemonic").split(" ").length).to be 24         
          # expect(wallet.fetch("mnemonic")).to be "something"       
        end
        
        # it "is something" do
        #   expect(subject).to eq("something") 
        # end

        it "has a response with one key named 'key'" do
          expect(subject.keys).to eq(["key"]) 
        end

        it "has a response 'key' with a value that is a String" do
          expect(subject.fetch("key").class).to be String 
        end
         it "has a response 'key' with a value that is at least 20 chars long" do
          expect(subject.fetch("key").length).to be > 20 
        end
        
        
      end
      
      
    


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
