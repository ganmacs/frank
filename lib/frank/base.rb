require 'rack'

 module Frank
  class Base
    class << self
      def inherited(base)
        base.reset
      end

      def reset
        @routes = {}
        @filter = { before: [], after: [] }
        @env = nil
        @request = nil
        @response = nil
      end

      # Rack interface
      def call(env)
        @env = env
        @request = Rack::Request.new(env)
        @response = Rack::Response.new

        invoke!

        [200, {}, @body]
      end

      def invoke!
        # TODO befoer
        key = route_key(@request.request_method, @request.path_info)
        @body = route_eval { @routes[key].call if @routes[key] }
        # TODO after
      end

      def route_eval
        yield
      end

      def get(path, &block)
        set_routes :GET, path, &block
      end

      def set_routes(type, path, &block)
        key = route_key(type, path)
        @routes[key] = block
      end

      def route_key(type, path)
        "#{type}_#{path}"
      end
    end
  end
end
