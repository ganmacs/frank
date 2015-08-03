require 'rack'
require 'frank/base'

module Frank
  class Main < Base
    SERVERS = %w(thin webrick).freeze

    class << self
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

    get "/" do
      "root"
    end
  end
end

Frank::Main.run!
