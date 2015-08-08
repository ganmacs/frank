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
      let(:response) { Rack::MockRequest.new(test_app).get('/') }

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq 'root'
      end

      context 'with args' do
        let(:name) { 'ganmacs' }
        let(:response) { Rack::MockRequest.new(test_app).get("/user/#{name}") }

        it 'processes requests with #call' do
          expect(response).to be_ok
          expect(response.body).to eq name
        end
      end
    end
  end
end
