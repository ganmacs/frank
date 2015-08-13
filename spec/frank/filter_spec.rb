describe Frank::Base do
  describe 'filter method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        before { @global_config = 'Hello World' }
        after { $stdin.puts 'hoge' }

        get('/global') { @global_config }
      end
    end

    let(:response) do
      Rack::MockRequest.new(test_app).get('global')
    end

    it 'processes requests with #call' do
      expect(response).to be_ok
      expect(response.body).to eq 'Hello World'
    end
  end

  describe 'filter method that has specifi method' do
    let(:test_app) do
      Class.new(Frank::Base) do |_x|
        before '/posts' do
          @global_config = 'Hello World in post'
        end

        get('/posts') { @global_config }
        get('/not_filtered_posts') { @global_config }
      end
    end

    let(:response) do
      Rack::MockRequest.new(test_app).get(method)
    end

    context 'with filtered method' do
      let(:method) { '/posts' }

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq 'Hello World in post'
      end
    end

    context 'withtout filterd method' do
      let(:method) { '/not_filtered_posts' }

      it 'processes requests with #call' do
        expect(response).to be_ok
        expect(response.body).to eq ''
      end
    end
  end
end
