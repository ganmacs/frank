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
end
