puts "loading env.rb"

require 'capybara'
require 'capybara/dsl'
require "capybara/cucumber"
require 'capybara/poltergeist'
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Capybara.default_driver = :poltergeist

# Can be slow with empty caches, give it some time.
Capybara.default_wait_time = 30

# Auto retry for simple failures because sites are very slow on initial build.
def retry_on_timeout(n = 3, &block)
  block.call
# Capybara::Poltergeist::TimeoutError doesn't extend Capybara::TimeoutError... boo!
# rescue Capybara::TimeoutError, Capybara::ElementNotFound => e
rescue => e
  if n > 0
    backoff = 5 ** (3 - n)
    puts "Retrying: " + Capybara.app_host + current_path
    sleep backoff

    # Refresh the page.
    visit current_path
    sleep backoff
    retry_on_timeout(n - 1, &block)
  else
    error_message =  e.message + "\nI gave up retrying, here's your broken page, you figure it out:\n" + body
    raise e.class, error_message
  end
end
