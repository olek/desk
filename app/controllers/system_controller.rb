class SystemController < ApplicationController
  def healthcheck
    render(
      text: Cowsay.say('Here!'),
      content_type: 'text/plain'
    )
  end

  def console
  end
end
