# frozen_string_literal: true

require_relative "tatum_web3/version"
require "httparty"
require "dry-struct"


module TatumWeb3
  class Error < StandardError; end
  # Your code goes here...

  module Types
    include Dry.Types()
  end

  ROUTES = {
    generate_flow_wallet: {
      method: "get",
      path: "/flow/wallet"
    },
    deploy_flow_nft: {
      method: "post",
      path: "/nft/deploy/"
    },
    generate_private_key: {
      method: "post",
      path: "/flow/wallet/priv"
    },

    generate_flow_account_address_from_extended_public_key: {
      method: "get",
      path: "/flow/address/:xpub/:index",
    },

    mint_nft: {
      method: "post",
      path: "/nft/mint/"
    },

    mint_nft_multiple_tokens: {
      method: "post",
      path: "/nft/mint/batch"
    },

    transfer_nft_token: {
      method: "post",
      path: "/nft/transaction/"
    },

    burn_nft: {
      method: "post",
      path: "/nft/burn/"
    },

    get_nft_tokens_by_address: {
      method: "get",
      path: "/nft/balance/:chain/:contractAddress/:address"
    },

    get_token_metadata: {
      method: "get",
      path: "/nft/metadata/:chain/:contractAddress/:token?account=0x2d0d7b39db4e3a08"
    },

    get_contract_address: {
      method: "get",
      path: "/nft/address/:chain/:txId"
    },

    get_nft_transaction: {
      method: "get",
      path: "/nft/address/:chain/:txId"
    },

    get_account: {
      method: "get",
      path: "/flow/account/:address"
    }

  }.freeze

  def self.routes
    ROUTES
  end

  # deals solely with how to create access to the resource, the lock of "lock & key"
  class Connection
    # concerned only on where it gets the info it needs
    # and maybe a version number

    include HTTParty
    debug_output $stdout
    # currently Touring Plans has no verision in its API
    DEFAULT_API_VERSION   = "3"
    DEFAULT_BASE_URI      = "https://api-us-west1.tatum.io"
    # do not freeze DEFAULT_QUERY
    DEFAULT_QUERY         = {}
    DEFAULT_HEADERS       = {}

    base_uri DEFAULT_BASE_URI

    def initialize(options = {})
      @api_version = options.fetch(:api_version, DEFAULT_API_VERSION)
      @query       = options.fetch(:query, DEFAULT_QUERY)
      @headers     = options.fetch(:headers, DEFAULT_HEADERS)
      @connection  = self.class
    end

    def query(params = {})
      @query.update(params)
    end

    def headers(params = {})
      @headers.update(params)
    end

    def get(relative_path, query = {}, headers = {})
      relative_path = add_api_version(relative_path)
      connection.get relative_path, query: @query.merge(query), headers: @headers.merge(headers)
    end

    private

    attr_reader :connection
    # currently tatum has a verision in its API

    def add_api_version(relative_path)
      "/#{api_version_path}#{relative_path}"
    end

    def api_version_path
      "v" + @api_version.to_s
    end

    def add_path_variables_in_order(relative_path)
      "#{relative_path}#{path_varibles}"
    end
    def path_variables(ordered_params = {})
      
    end
  end

  # deals solely with how to manage the connection, the key of "lock & key"
  class Client
    def initialize(connection:, routes:)
      @connection = connection
      @routes     = routes
    end

    def method_missing(method, *request_arguments)
      # retrieve the route map
      route_map = routes.fetch(method)

      # make request via the connection
      response_from_route(route_map, request_arguments)
    end

    private

    attr_reader :connection, :routes

    def response_from_route(route_map, request_arguments)
      # gather the routes required parameters
      http_method   = route_map.fetch(:method)
      relative_path = route_map.fetch(:path)

      # call the connection for records
      connection.send(http_method, relative_path, *request_arguments)
    end
  end


end
