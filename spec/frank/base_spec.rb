describe Frank::Base do
  describe 'creates GET method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        get '/' do
          'root'
        end

        get '/posts' do         # with params
          params['page']
        end

        get '/user/:name' do |name|
          name
        end
      end
    end

    let(:response) do
      Rack::MockRequest.new(test_app).get(path)
    end

    context 'with normal condition' do
      let(:path) do
        '/'
      end

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq 'root'
      end
    end

    context 'with args' do
      let(:name) { 'ganmacs' }
      let(:path) do
        "/user/#{name}"
      end

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq name
      end
    end

    context 'with paramsa' do
      let(:page) { '50' }
      let(:path) do
        "/posts?page=#{page}"
      end

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq page
      end
    end
  end

  describe 'Does not maintain the state' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        get '/unmaintain' do
          @foo ||= 'foo'
          @foo = "#{@foo}_bar"
          @foo
        end
      end
    end

    it 'processes requests with #call' do
      2.times do
        response = Rack::MockRequest.new(test_app).get('/unmaintain')
        expect(response).to be_ok
        expect(response.body).to eq 'foo_bar'
      end
    end
  end

  describe 'creates POST method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        post '/message' do
          params['body']
        end
      end
    end

    let(:response) do
      Rack::MockRequest.new(test_app).post(path, opt)
    end

    context 'with normal condition' do
      let(:path) { '/message' }
      let(:opt) do
        {
          params: {
            body: 'this is body'
          }
        }
      end

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq opt[:params][:body]
      end
    end
  end

  describe 'creates DELETE and PUT method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        delete '/user/:id' do |id|
          "delete #{id}"
        end

        put '/user/:id' do |id|
          "update #{id}"
        end
      end
    end

    let(:response_mock_generator) do
      Rack::MockRequest.new(test_app)
    end

    context 'DELETE method' do
      let(:response) { response_mock_generator.delete('/user/2') }

      it 'process requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq 'delete 2'
      end
    end

    context 'PUT method' do
      let(:response) { response_mock_generator.put('/user/3') }

      it 'process requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq 'update 3'
      end
    end
  end
end
