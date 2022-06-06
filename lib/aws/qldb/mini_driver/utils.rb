# frozen_string_literal: true

module Aws
  module QLDB
    module MiniDriver
      module Utils # rubocop:disable Style/Documentation
        def hash_comparator(hash1, hash2)
          (hash1.length - 1).downto(0).each do |i|
            difference = ((hash1[i].unpack1("c") << 24) >> 24) - ((hash2[i].unpack1("c") << 24) >> 24)
            return difference if difference != 0
          end
          0
        end

        def join_hashes_pairwise(hash1, hash2)
          return hash2 unless hash1.length.positive?
          return hash1 unless hash2.length.positive?

          if hash_comparator(hash1, hash2).negative?
            hash1 + hash2
          else
            hash2 + hash1
          end
        end

        def dot(hash1, hash2)
          concatenated = join_hashes_pairwise(hash1, hash2)
          Digest::SHA256.digest(concatenated)
        end

        def make_digest(value)
          Digest::SHA256.digest("\x0B\x80#{value}\x0E")
        end
      end
    end
  end
end
