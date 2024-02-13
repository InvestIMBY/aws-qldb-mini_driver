# frozen_string_literal: true

module Aws
  module QLDB
    module MiniDriver
      QLDB_CLIENT = Aws::QLDB::Client.new
      QLDB_SESSION_CLIENT = Aws::QLDBSession::Client.new
    end
  end
end
