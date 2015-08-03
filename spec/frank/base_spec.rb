describe Frank::Base do
  describe 'creates GET method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        get('/') { 'root' }
      end
    end

    let(:response) { Rack::MockRequest.new(test_app).get('/') }

    it 'processes requests with #call' do
      expect(response).to be_ok
      expect(response.body).to eq 'root'
    end
  end
end
