# frozen_string_literal: true

require "spec_helper"

RSpec.describe Aws::QLDB::MiniDriver do # rubocop:disable Metrics/BlockLength
  def stub_session
    stub_request(:post, "https://session.qldb.ap-northeast-1.amazonaws.com/")
      .with(body: '{"StartSession":{"LedgerName":"testLedger"}}')
      .to_return(status: 200, body: '{"StartSession":{"SessionToken":"token"}}')
  end

  def stub_transaction
    stub_request(:post, "https://session.qldb.ap-northeast-1.amazonaws.com/")
      .with(body: '{"SessionToken":"token","StartTransaction":{}}')
      .to_return(status: 200, body: '{"StartTransaction":{"TransactionId":"xxx"}}')
  end

  def stub_execution
    stub_request(:post, "https://session.qldb.ap-northeast-1.amazonaws.com/")
      .with(body: '{"SessionToken":"token","ExecuteStatement":{"Statement":'\
        '"INSERT INTO test VALUE { \'name\' : \'Name\' }","TransactionId":"xxx"}}')
      .to_return(status: 200, body: '{"ExecuteStatement":{"FirstPage":'\
        '{"Values":[{"IonBinary":"abcdefghijklmnopqrtsuv"}]}}}')
  end

  def stub_commit
    stub_request(:post, "https://session.qldb.ap-northeast-1.amazonaws.com/")
      .with(body: '{"SessionToken":"token","CommitTransaction":{"CommitDigest":'\
        '"7XILGj7FXYNHmex3pxDCzmWKlzrAnM+s2crCsPr1Bj8=","TransactionId":"xxx"}}')
      .to_return(status: 200, body: '{"CommitTransaction":{}}')
  end

  before do
    stub_session
    stub_transaction
    stub_execution
    stub_commit
  end

  it "should run insert query without causing an error" do
    expect do
      transaction = Aws::QLDB::MiniDriver::Session.start("testLedger").start_transaction
      transaction.insert("INSERT INTO test VALUE { 'name' : 'Name' }")
      transaction.commit
    end.not_to raise_error
  end
end
