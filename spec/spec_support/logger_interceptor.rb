module LoggerInterceptor
  # will let you intercept the logged data for current spec
  # use:
  #   steal_logger!
  #   post(....)
  #   expect(app.logger.log).not_to include "secret_accountid_12345"
  #   release_logger!
  #
  # will catch any logging of messages. E.g.:
  #   logger.debug params.to_s
  #   logger.info params.to_s
  #   logger.warn params.to_s
  #   logger.fatal params.to_s
  #   logger.add 1, params.to_s
  #
  # Ensure `release_logger!` is called after each spec ends.

  def steal_logger!
    current_logger= app.logger

    if defined?(@@old_logger) && @@old_logger.nil?.!
      raise RuntimeError, "Logger was already stolen. Release the logger after each use case."
    else
      @@old_logger= current_logger
    end

    def current_logger.add_instace_log
      @log="" unless defined?(@log)
    end
    current_logger.add_instace_log

    class << current_logger
      def add(severity, message = nil, progname = nil)
        @log+= message.to_s
        @log+= progname.to_s
      end

      def log
        @log.to_s
      end
    end

    allow_any_instance_of(app).to receive(:logger).and_return current_logger
    current_logger
  end

  def release_logger!
    return if defined?(@@old_logger).! || @@old_logger.nil?
    current_logger= app.logger

    allow_any_instance_of(app).to receive(:logger).and_return @@old_logger
    @@old_logger = nil

    def current_logger.remove_instace_log
      remove_instance_variable("@log") if defined?(@log)
    end
    current_logger.remove_instace_log

    class << current_logger
      remove_method :add
      remove_method :log
      remove_method :remove_instace_log
      remove_method :add_instace_log
    end

  end
end
