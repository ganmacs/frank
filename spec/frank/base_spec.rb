describe Frank::Base do
  describe 'creates GET method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        get '/' do
          'root'
        end

        get '/user/:name' do |name|
          name
        end
      end
    end

    context 'GET method' do
      let(:response) { Rack::MockRequest.new(test_app).get(path) }

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
      end
    end
  end
end
