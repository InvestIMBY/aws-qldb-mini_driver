# frozen_string_literal: true

require_relative "lib/aws/qldb/mini_driver/version"

Gem::Specification.new do |spec|
  spec.name = "aws-qldb-mini_driver"
  spec.version = Aws::QLDB::MiniDriver::VERSION
  spec.authors = ["Mathieu Jobin", "Pete Henchaw"]
  spec.email = ["mathieu@addyinvest.com", "peter@addyinvest.com"]

  spec.summary = "QLDB Minidriver for Ruby"
  spec.description = "Non-parametrized queries/DML for QLDB and basic transaction management."
  spec.homepage = "https://github.com/InvestIMBY/aws-qldb-mini_driver"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://addyinvest.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/InvestIMBY/aws-qldb-mini_drive"
  spec.metadata["changelog_uri"] = "https://github.com/InvestIMBY/aws-qldb-mini_driver/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-qldb"
  spec.add_dependency "aws-sdk-qldbsession"
end
