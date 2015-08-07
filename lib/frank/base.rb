require 'rack'

module Frank
  class Base
    SERVERS = %w(thin webrick).freeze

    class << self
      def inherited(base)
        base.reset
      end

      attr_reader :routes, :filters

      def configs
        self
      end

      def reset
        @routes = Hash.new([])
        @filters = { before: [], after: [] }
      end

      # for Rack interface
      def call(env)
        prototype.call(env)
      end

      def prototype
        @prototype ||= new
      end

      def get(path, &block)
        set_routes :GET, path, &block
      end

      def set_routes(type, path, &block)
        method_name = "#{type}_#{path}"
        @routes[type] << [method_name, path, block]
      end

      def run!
        handler = detect_rack_handler

        start_server(handler)
      end

      # @param [Rack::Handler] handler is Rack handler
      def start_server(handler, options = {})
        handler.run(self, options)
      end

      # @return [Rack::Handler] Rack handler
      def detect_rack_handler
        servers = Array(SERVERS)
        servers.each do |server|
          begin
            return Rack::Handler.get(server)
          rescue LoadError
          end
        end
      end
    end

    def configs
      self.class.configs
    end

    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @response = Rack::Response.new

      invoke

      @response.finish
    end

    def invoke
      # TODO befoer
      routes!
      # TODO after
    end

    def routes!(base = configs)
      pass = nil

      if (routes = base.routes[@request.request_method.to_sym])
        routes.each do |method_name, path, block|
          pass = block.call if path == @request.path_info
        end
      end

      @response.write(pass)
      @body = pass
    end

    def route_eval
      yield
    end
  end
end
