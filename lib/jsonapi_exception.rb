require "jsonapi_exception/version"

class JsonapiException
  DEFAULT_STATUS = 422
  MIME_TYPE = "application/vnd.api+json".freeze

  def initialize(exception, opts = {})
    @exception = exception
    @opts      = opts
  end

  def title
    opts.fetch(:title)
  rescue KeyError
    exception
      .class
      .to_s
      .split("::")
      .last
      .scan(/([A-Z][^A-Z]*)/)
      .join(" ")
      .sub(/ (Error|Exception)$/, "")
  end

  def detail
    opts.fetch(:detail, exception.message)
  end

  def status
    opts.fetch(:status, DEFAULT_STATUS)
  end

  def id
    opts.fetch(:id, exception.object_id)
  end

  def code
    opts[:code]
  end

  def links
    opts[:links]
  end

  def meta
    return opts[:meta] if opts[:meta]
    return unless show_exceptions?
    {
      class:     exception.class.to_s,
      message:   exception.message,
      backtrace: exception.backtrace
    }
  end

  def as_json(*_)
    {
      errors: [to_h]
    }
  end

  def to_h
    {
      title:  title,
      links:  links,
      detail: detail,
      status: status.to_s,
      id:     id,
      code:   code
    }.reject { |_, v| !v }
  end

  def for_render
    {
      json:         as_json,
      status:       status,
      content_type: MIME_TYPE
    }
  end

  private

  attr_reader :exception, :opts

  def show_exceptions?
    return false unless defined?(Rails)
    Rails.application.config.action_dispatch.show_exceptions
  end
end
