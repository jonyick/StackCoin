require "toro"

class StackCoin::Api < Toro::Router
  def routes
    get do
      html "src/views/home"
    end
  end

  def self.run!
    Api.run 3000
  end
end
