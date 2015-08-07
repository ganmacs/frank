require 'frank/base'

module Frank
  class Main < Base
    get '/' do
      'root'
    end
  end
end

at_exit { Frank::Main.run! }
