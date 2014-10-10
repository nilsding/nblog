require File.expand_path "../spec_helper.rb", __FILE__

describe "nblog" do
  it "should allow accessing the home page" do
    visit "/"
    expect(page.status_code).to be(200)
  end
  
  it "should not be able to access the logout page via GET" do
    visit "/logout"
    expect(page.status_code).to be(403)
  end
  
  it "should set a user-defined stylesheet" do
    cssfile = "http://test.nilsding.org/nblog2.css"
    
    visit "/?css=%20%20%20%20#{cssfile}%20%20%20%20"
    expect(page.status_code).to be(200)
    expect(page).to have_xpath("//link[@rel='stylesheet' and @href='#{cssfile}']")
    
    visit "/?css=%20%20%20%20"
    expect(page).to have_xpath("//link[@rel='stylesheet' and @href='/assets/style.css']")
  end
end

# kate: indent-width 2