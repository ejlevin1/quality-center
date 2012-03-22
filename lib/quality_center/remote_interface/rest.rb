require 'httparty'
require_relative 'exceptions'
require_relative '../constants'

module QualityCenter
  module RemoteInterface
    class Rest

      include HTTParty
      base_uri 'qualitycenter.ic.ncs.com:8080'
      def initialize(u,p)
        @login = {:j_username => u, :j_password => p}
        @cookie = ''
      end

      def login
        response = self.class.get AUTHURI[:get]
        response = self.class.post(
          AUTHURI[:post],
          body:    @login,
          headers: {'Cookie' => response.headers['Set-Cookie']}
        )
        raise LoginError, "Bad credentials" if response.request.uri.to_s =~ /error/

        @cookie = response.request.options[:headers]['Cookie']
        response
      end

      # Retrieve the contents of a path, respecting authentication cookies.
      # 
      # path - The url fragment to fetch.  Will be concatenated with PREFIX
      # opts - :prefix - The string to prepend to the path
      #                  default: PATH
      #        :raw    - Whether to return unprocessed raw XML, or a parsed hash
      #                  default: false
      # Examples
      #
      #   auth_get('/entities')
      #   # => (array of Entity hashes)
      #
      #   auth_get('/somethings', raw:true)
      #   # => "<xml><somethings></somethings></xml>"
      #
      # Returns a hash or string representing the requested resource
      def auth_get(path,opts={})
        opts.reverse_merge!(prefix:PREFIX, raw:false)
        url = opts[:prefix] + path
        assert_valid(res = stateful_get(url) )

        # return raw xml if caller wants it,    otherwise a hash.
        return opts[:raw] ? res.response.body : res.parsed_response
      end

      def users(opts={})
        scoped_get('/customization/users',opts)
      end

      def defects(opts={})
        scoped_get('/defects',opts)
      end

      def defect_fields(opts={})
        scoped_get('/customization/entities/defect/fields',opts)
      end

      # get a path scoped to a predefined domain and project
      def scoped_get(path,opts={})
        auth_get(SCOPE+path,opts)
      end

      def authenticated?
        return false if @cookie.empty?
        return case self.class.get('/qcbin/rest/is-authenticated',
                                   headers: {'Cookie' => @cookie}).response.code
          when '200' then true
          else false
        end
      end

    private

      # Check that a HTTP response is OK.
      def assert_valid(res)
        raise LoginError, res.response.code          if res.response.code == '401'
        raise UnrecognizedResponse,res.response.code if res.response.code != '200'
      end

      # Get somethig using the cookie
      def stateful_get(url)
        raise NotAuthenticated if @cookie.empty?
        self.class.get( url, headers: {'Cookie' => @cookie} )
      end


    end
  end
end
