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
  
  it "should display a 404 page when a site was not found" do
    visit "/this-page-does-not-exist"
    expect(page.status_code).to be(404)
    
    expect(page).to have_content("404")
  end
  
  it "should display the about page" do
    visit "/about"
    
    expect(page).to have_content("About")
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
    
    it "should not be able to publish an empty post" do
      text = "            "

      session.visit "/"
      session.fill_in "What's happening?", with: text
      session.click_button "Publish"

      expect(session).to have_content("Post cannot be empty")
    end

    it "should edit a new post" do
      text = "This is an example text."
      updated_text = "This is an example text that was updated."

      session.visit "/"
      session.click_link "[e]"

      expect(session.current_url).to match(/\/edit$/)
      expect(session).to have_content(text)
      session.fill_in "What's happening?", with: updated_text
      session.click_button "Update"

      session.visit "/"
      expect(session).to have_content("[l] #{updated_text}")
    end

    it "should publish a post with multiple links and more" do
      text = "I really love [this site](http://example.com), especially when it comes _to [this](http://example.com/LOL)_."
      stripped =  "I really love this site, especially when it comes to this."

      session.visit "/"
      session.fill_in "What's happening?", with: text
      session.click_button "Publish"

      expect(session).to have_content("[l] #{stripped}")
    end

    it "should see the RSS feed title with the HTML tags stripped" do
      session.visit "/feed.xml"
      expect(session.find(:xpath, "//item[1]/title")).to have_text("I really love this site, especially when it comes to this.")
    end

    it "should delete a post" do
      text = "I really love this site"

      session.visit "/"
      expect(session).to have_content("[l] #{text}")
      session.click_link "[e]", match: :first

      expect(session.current_url).to match(/\/edit$/)
      session.click_button "Delete"

      session.visit "/"
      expect(session).not_to have_content("[l] #{text}")
    end
    
    it "should view a post" do
      session.visit "/"
      session.click_link "[l]", match: :first
      
      expect(session.current_url).to match(/\/p\/\d+$/)
      expect(session).to have_content("View post")
    end
    
    it "should get the post in YAML format" do
      session.visit "/p/1.yml"
      expect(session).to have_content("---\nid: 1")
    end
    
    it "should get the post in JSON format" do
      session.visit "/p/1.json"
      expect(session).to have_content("{\"id\":1,")
    end
    
    it "should return a 404 error if a post was not found" do
      session.visit "/p/12357832"
      expect(session.status_code).to be(404)
    end
  end
end

# kate: indent-width 2
