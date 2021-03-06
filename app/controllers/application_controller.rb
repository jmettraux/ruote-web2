# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ErrorReply < Exception

  attr_reader :status

  def initialize (msg, status=400)
    super(msg)
    @status = status
  end
end


class ApplicationController < ActionController::Base

  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #
  protect_from_forgery # :secret => '6cf53db50644a9077b1b88dc521a2b56'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like
  # "password").
  #
  # filter_parameter_logging :password

  def error_reply (error_message, status=400)

    if error_message.is_a?(ErrorReply)
      status = error_message.status
      error_message = error_message.message
    end

    flash[:error] = error_message

    plain_reply = lambda() {
      render(
        :text => error_message,
        :status => status,
        :content_type => 'text/plain')
    }

    respond_to do |format|
      format.html { redirect_to '/' }
      format.json &plain_reply
      format.xml &plain_reply
    end
  end

  rescue_from(ErrorReply) { |e| error_reply(e) }

  #
  # Returns a new LinkGenerator wrapping the current request.
  #
  def linkgen

    LinkGenerator.new(request)
  end

  #
  # Creates an HistoryEntry record
  #
  def history_log (event, options={})

    source = options.delete(:source) || current_user.login

    OpenWFE::Extras::HistoryEntry.log!(source, event, options)
  end

  #
  # Should return the path to the partial in charge of rendering the
  # workitem payload.
  #
  # This initial implementation is rather, plain. Rewrite at will.
  #
  def determine_payload_partial (workitem)

    'shared/ruote_forms'
  end
end

#
# the ?plain=true trick
#
class ActionController::MimeResponds::Responder

  # TODO : use method_alias_chain ...

  unless public_instance_methods(false).include?('old_respond')
    alias_method :old_respond, :respond
  end

  def respond

    old_respond

    @controller.response.content_type = 'text/plain' \
      if @controller.request.parameters['plain'] == 'true'
  end
end

