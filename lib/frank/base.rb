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

      def post(path, &block)
        set_routes :POST, path, &block
      end

      def set_routes(type, path, &block)
        method_name = "#{type}_#{path}"
        path_pattern = generate_path_pattern(path)
        unbound_method = generate_method(method_name, block)
        wrapped = wrap_block(unbound_method)
        @routes[type] << [path_pattern, wrapped]
      end

      # We use unboundMethod instead of lambda,
      # bacause use instance variable such as @params in user defined method
      # @return [UnboundMethod]
      def generate_method(method_name, block)
        method_name = method_name.to_sym
        define_method(method_name, &block)
        method = instance_method(method_name)
        remove_method(method_name)
        method
      end

      # @params [UnboundMethod] block
      def wrap_block(unbound_method)
        if unbound_method.arity == 0
          proc { |obj, _args| unbound_method.bind(obj).call }
        else
          proc { |obj, args| unbound_method.bind(obj).call(*args) }
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

    attr_reader :params

    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @params = @request.params

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
        block.call(self, args)
      end
    end
  end
end
