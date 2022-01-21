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


  }.freeze

  def self.routes
    RoutesTable.load_routes_file(routes_relative_file_path: "/routes.yml")
  end

  # deals solely with how to create access to the resource, the LOCK of "lock & key"
  class Connection
    # concerned only on where it gets the info it needs
    # and maybe a version number

    include HTTParty
    debug_output $stdout
    # currently Tatum has a verisioned API
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

    def get(relative_path, query = {}, headers = {}, path_vars = {})
    #  relative_path for 
      relative_path = add_api_version(relative_path)
      # relative_path plus tail-end vars
      # path: "/nft/address/:chain/:txId"
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

  # deals solely with how to manage the connection, the KEY of "lock & key"
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

  # Generates and updates routes for all types of venues in a YAML document.
  class RoutesTable
    require "fileutils"
    def initialize(filename: "routes_table.yml")
      @filename = filename
    end

    def self.original_routes
      # this method exists so that we can create a yaml file of routes
      tw3 = TatumWeb3.routes
      # convert symbols back to strings
      stringify_keys(tw3)
      # rt_keys       = tw3.keys
      # rt_values     = tw3.values
      # string_keys   = []

      # rt_keys.each {|k| string_keys << k.to_s}
      # # create new hash with string keys
      # string_keys.zip(rt_values).to_h
    end

    def self.symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
      end
    end

    def self.stringify_keys(hash)
      # inspired by https://avdi.codes/recursively-symbolize-keys/
      hash.each_with_object({}) do |(key, value), result|
        new_key = case key
                  when Symbol then key.to_s
                  else key
                  end
        new_value = case value
                    when Hash then stringify_keys(value)
                    else value
                    end
        result[new_key] = new_value
      end
    end

    def self.load_routes_file(routes_relative_file_path: "/routes.yml")
      tp_path = $LOAD_PATH.grep(/tatum_web3/).last
      routes_file = "#{tp_path}#{routes_relative_file_path}"
      YAML.safe_load(File.read(routes_file))
    end

    def self.update_file
      # gather info into hashes
      attractions_routes    = _generate_interest_routes_hash("attractions")
      dining_routes         = _generate_interest_routes_hash("dining")
      hotels_routes         = _generate_interest_routes_hash("hotels")
      updated_routes        = original_routes.merge(attractions_routes, dining_routes, hotels_routes)

      updated_routes_yaml   = _convert_hash_to_yaml(updated_routes)

      file = _initialize_file
      _save_content_to_file(file, updated_routes_yaml)
    end

    def self._initialize_file
      # delete old file if it exits
      lib_dir = FileUtils.getwd + "/lib"
      routes_file = "#{lib_dir}/routes.yml"

      # ensure the file exists
      touched_routes_file_array = FileUtils.touch(routes_file)
      # we want the first string value
      touched_routes_file_array.first
    end

    def self._generate_interest_routes_hash(interest)
      interest_venues = Touringplans.list_all(interest)
      interest_routes = {}

      interest_venues.each do |iv|
        new_route = _generate_interest_route(iv.venue_permalink, interest, iv.permalink)
        key = new_route.keys.first
        values = new_route[key]
        interest_routes[key] = values
      end

      interest_routes
    end

    def self._generate_interest_route(venue_permalink, interest_permalink, place_permalink)
      # {magic_kingdom_attractions_haunted_mansion: {
      #   method: "get",
      #   path: "/magic-kingdom/attractions/haunted-mansion.json"
      #   }
      # }
      path    = "/#{venue_permalink}/#{interest_permalink}/#{place_permalink}"
      key     = path.to_s.downcase.gsub("/", " ").gsub("-", " ").strip
      key     = key.gsub(" ", "_")
      method  = "get"
      format  = "json"

      { key => { "method".to_s => method,
                 "path".to_s => "#{path}.#{format}" } }
    end

    def self._convert_hash_to_yaml(hash)
      hash.to_yaml
    end

    def self._save_content_to_file(file, content)
      new_file = File.open(file, "w")
      new_file.write(content)
      new_file.close
    end

    def self._read_file_to_terminal(file)
      new_file = File.open(file, "r")
      new_file.close
    end
  end

  def self._assemble_route(path_variables)
    # format route
    collection    = collection.to_s.downcase.gsub(" ", "_").gsub("-", "_")
    interest_type = interest_type.to_s.downcase.gsub(" ", "_").gsub("-", "_")
    venue         = venue.to_s.downcase.gsub(" ", "_").gsub("-", "_")

    route = [collection, interest_type, venue].join("_")
    route = [collection, interest_type].join("_") if venue == "list"

    route
  end

end
