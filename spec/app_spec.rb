require File.expand_path "../spec_helper.rb", __FILE__

describe "nblog" do
  it "should allow accessing the home page" do
    visit "/"
    expect(page.status_code).to be(200)
  end
  
  it "should forbid the logout page via GET" do
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
  
  context "user" do
    session = Capybara::Session.new(:rack_test, NBlog::Application)
    it "should not sign in with wrong username/password combination" do
      session.visit "/"
      session.click_on "Login"
      expect(session.current_url).to match(/\/login$/)
      session.fill_in "User name", with: "EpicLPer"
      session.fill_in "Password", with: "horsehorsehorse"
      session.click_button "Sign in"
      
      expect(session.current_url).to match(/\/login$/)
      expect(session).to have_content("Wrong user")
    end
    
    it "should sign in" do
      session.visit "/"
      session.click_on "Login"
      expect(session.current_url).to match(/\/login$/)
      session.fill_in "User name", with: "test"
      session.fill_in "Password", with: "secret"
      session.click_button "Sign in"
      
      expect(session.current_url).to match(/\/$/)
      expect(session).to have_content("Successfully logged in")
    end
    
    it "should stay signed in" do
      session.visit "/"
      expect(session).to have_content("Logout")
    end
    
    it "should publish a new post" do
      text = "This is an example text."
      
      session.visit "/"
      session.fill_in "What's happening?", with: text
      session.click_button "Publish"
      
      expect(session).to have_content("[l] #{text}")
    end
  end
end

# kate: indent-width 2