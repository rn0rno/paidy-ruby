RSpec.describe Paidy do
  it "has a version number" do
    expect(Paidy::VERSION).not_to be nil
  end

  describe "Object#request" do
    context "do not set secret_key" do
      it "raise AuthenticationError" do
        expect{ Paidy.request(:post, '/', {}, {}) }.to raise_error(Paidy::AuthenticationError)
      end
    end
  end
end
