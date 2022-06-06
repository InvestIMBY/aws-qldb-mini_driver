# frozen_string_literal: true

module Aws
  module QLDB
    module MiniDriver
      class Session # rubocop:disable Style/Documentation
        def self.start(ledger)
          resp = QLDB_SESSION_CLIENT.send_command(start_session: { ledger_name: ledger })
          new resp.start_session.session_token
        end

        def initialize(token)
          @token = token
        end

        def start_transaction
          resp = QLDB_SESSION_CLIENT.send_command(session_token: @token, start_transaction: {})
          Transaction.new resp.start_transaction.transaction_id, @token
        end
      end
    end
  end
end
