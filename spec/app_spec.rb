require File.expand_path "../spec_helper.rb", __FILE__

describe "nblog" do
  it "should allow accessing the home page" do
    get "/"
    expect(last_response).to be_ok
  end
  it "should not be able to access the logout page via GET" do
    get "/logout"
    expect(last_response).not_to be_ok
  end
end

# kate: indent-width 2