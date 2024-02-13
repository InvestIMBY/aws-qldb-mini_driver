# frozen_string_literal: true

require "spec_helper"

RSpec.describe Aws::QLDB::IonParser do
  let(:ion_binary) do
    "\xE0\x01\x00\xEA\xEE\xFB\x81\x83\xDE\xF7\x87\xBE\xF4\x8CblockAddress\x88strandId\x8AsequenceNo\x84hash\x84data" \
      "\x84guid\x86amount\x88currency\x84type\x83ref\x86source\x8Bdestination\x88metadata\x82id\x86txTime\x84txId\xDE" \
      "\x02\xCF\x8A\xDE\x9D\x8B\x8E\x96I1pHWLIr136J7WUAlMmtYW\x8C\"\x01%\x8D\xAE\xA0\xEA\xC2\x85\xCF\x9B\xAAl\xD7\x88" \
      "\xCE\x96\\E\n\xEB\x82\x91\xBC\xE2q\x1C\xB7\x8B{\xE7=4z\r \x17\xA4\x8E\xDE\x01\xC4\x8F\x8E\xA4" \
      "10f28c61-2ad5-4204-80c6-9d67d182bff5\x90R\xC1d\x91\x83USD\x92\x83ABC\x93\x877gw2syq\x94\x8E\xC0" \
      "24c6b99678199ecc94a73adf1af73af426923bfc20e6c81633a950ed6087c2eb\x95\x8E\xC0a16e6870bc876c2b49e8517330d529" \
      "bedd0c6f774fdb9df08303a69bb4f44878\x96\xDE\xC1\x97\x8E\x960QcFYGKuLGFG7z2SFyNX8O\x85 \x98k\x80\x0F\xE8\x82\x88" \
      "\x94\x8B\x93\xC3\x015\x99\x8E\x96GzwzG7xhTtKKoPxeiIA3Mj"
  end

  let(:expected_result) do
    { "blockAddress" => { "sequenceNo" => 293, "strandId" => "I1pHWLIr136J7WUAlMmtYW" },
      "data" => { "amount" => 10, "currency" => "USD",
                  "destination" => "a16e6870bc876c2b49e8517330d529bedd0c6f774fdb9df08303a69bb4f44878",
                  "guid" => "10f28c61-2ad5-4204-80c6-9d67d182bff5", "ref" => "7gw2syq",
                  "source" => "24c6b99678199ecc94a73adf1af73af426923bfc20e6c81633a950ed6087c2eb", "type" => "ABC" },
      "hash" => "6sKFz5uqbNeIzpZcRQrrgpG84nEct4t75z00eg0gF6Q=",
      "metadata" => { "id" => "0QcFYGKuLGFG7z2SFyNX8O", "txId" => "GzwzG7xhTtKKoPxeiIA3Mj",
                      "txTime" => Time.parse("2024-02-08 20:11:19.309000000 +0000") } }
  end

  it "should run insert query without causing an error" do
    expect(described_class.parse(ion_binary)).to eq expected_result
  end
end
