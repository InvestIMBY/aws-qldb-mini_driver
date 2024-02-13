# frozen_string_literal: true

module Aws
  module QLDB
    module MiniDriver
      class Transaction # rubocop:disable Style/Documentation
        include Utils

        def initialize(transaction_id, token)
          @transaction_id = transaction_id
          @token = token
          @digest = make_digest(transaction_id)
        end

        def execute(statement)
          resp = QLDB_SESSION_CLIENT.send_command(session_token: @token, execute_statement: {
                                                    statement: statement, transaction_id: @transaction_id
                                                  })
          @digest = dot(@digest, make_digest(statement))
          resp
        end

        def fetch_page(next_page_token)
          QLDB_SESSION_CLIENT.send_command(session_token: @token, fetch_page: {
            next_page_token: next_page_token, transaction_id: @transaction_id
          })
        end

        def insert(statement)
          resp = execute(statement)
          resp.execute_statement.first_page.values.first.ion_binary[-22..]
        end

        def commit
          QLDB_SESSION_CLIENT.send_command(session_token: @token, commit_transaction: {
                                             commit_digest: @digest, transaction_id: @transaction_id
                                           })
        end

        def abort
          QLDB_SESSION_CLIENT.send_command(session_token: @token, abort_transaction: {})
        end
      end
    end
  end
end
