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
        path_pattern = generate_path_pattern(path)
        wrapped = wrapp_block(block)
        @routes[type] << [path_pattern, wrapped]
      end

      def wrapp_block(block)
        if block.arity == 0
          proc { |args| block.call }
        else
          proc { |args| block.call(*args) }
        end
      end

      def generate_path_pattern(path)
        pattern = path.gsub(/:\w+/, '(\w+)')
         Regexp.new(pattern + '\Z')
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

    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @response = Rack::Response.new

      dispatch

      @response.finish
    end

    private

    def configs
      self.class.configs
    end

    def dispatch
      # TODO befoer
      routes!
      # TODO after
    end

    def routes!(base = configs)
      body = nil

      if (routes = base.routes[@request.request_method.to_sym])
        routes.each do |pattern, block|
          break if (body = process_route(pattern, block))
        end
      end

      @response.write(body)
    end

    def process_route(pattern, block)
      if (matched = pattern.match(@request.path_info))
        args = matched.captures
        block.call(args)
      end
    end
  end
end
