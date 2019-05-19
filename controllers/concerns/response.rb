module Response
  def bad_request(message = nil)
    @bad_request ||= {
      code: 400,
      body: {
        message: message || "Bad Parameters"
      }
    }
  end

  def response_body(code: , body:)
    @response_body ||= {
      code: code,
      body: body
    }
  end
end