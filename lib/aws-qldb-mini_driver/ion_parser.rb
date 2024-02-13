# frozen_string_literal: true

# rubocop:disable Metrics/*
module Aws
  module QLDB
    class IonParser
      ION_HEADER = [0xE0, 0x01, 0x00, 0xEA].freeze

      ION_MASK_LIST = 0xB0
      ION_MASK_DECIMAL = 0x50
      ION_MASK_INTEGER = 0x20
      ION_MASK_NEG_INTEGER = 0x30
      ION_MASK_TIMESTAMP = 0x60
      ION_MASK_STRING = 0x80
      ION_MASK_ANNOTATION = 0xE0
      ION_MASK_STRUCT = 0xD0
      ION_MASK_BLOB = 0xA0

      HIGH_NIBBLE = 0xF0
      LOW_NIBBLE = 0x0F

      def self.parse(binary)
        binary = binary.unpack("C*") if binary.is_a?(String)
        IonParser.new.parse(binary)
      end

      def parse(binary)
        return nil unless binary[0..3] == ION_HEADER

        index = 4
        parsed = sequence_parser(binary, index).first
        replace_keys(parsed.first[:annotation].first.values.first, parsed.last, parsed.last.keys.min)
      end

      private

      def replace_keys(annotations, numbered_key_hash, offset)
        numbered_key_hash.each_with_object({}) do |(key, val), hash|
          hash[annotations[key - offset]] = val.is_a?(Hash) ? replace_keys(annotations, val, offset) : val
        end.with_indifferent_access
      end

      def sequence_parser(binary, index)
        result = []
        while index < binary.length
          (res, index) = branch_parser(binary, index)
          result << res
        end
        [result, index]
      end

      def branch_parser(binary, index)
        result = case (binary[index] & HIGH_NIBBLE)
                 when ION_MASK_ANNOTATION
                   (length, index) = parse_length(binary, index)
                   # skip 0x81 0x83
                   { annotation: parse_list(binary[index + 2..index + length - 1]) }
                 when ION_MASK_STRUCT
                   (length, index) = parse_length(binary, index)
                   parse_hash(binary[index..index + length - 1])
                 when ION_MASK_LIST
                   (length, index) = parse_length(binary, index)
                   parse_list(binary[index..index + length - 1])
                 when ION_MASK_BLOB
                   (length, index) = parse_length(binary, index)
                   Base64.strict_encode64(binary[index..index + length - 1].pack("C*"))
                 when ION_MASK_STRING
                   (length, index) = parse_length(binary, index)
                   binary[index..index + length - 1].pack("C*")
                 when ION_MASK_INTEGER
                   (length, index) = parse_length(binary, index)
                   if length.zero?
                     0
                   else
                     parse_uint(binary[index..index + length - 1])
                   end
                 when ION_MASK_NEG_INTEGER
                   (length, index) = parse_length(binary, index)
                   -1 * parse_uint(binary[index..index + length - 1])
                 when ION_MASK_DECIMAL
                   (length, index) = parse_length(binary, index)
                   parse_decimal(binary[index..index + length - 1])
                 when ION_MASK_TIMESTAMP
                   (length, index) = parse_length(binary, index)
                   parse_timestamp(binary[index..index + length - 1])
        end

        [result, index + length]
      end

      def parse_length(binary, index)
        length = binary[index] & LOW_NIBBLE
        index += 1
        return [0, index] if length == 0x0F
        return [length, index] if length < 0x0E

        length = 0
        if (binary[index] & HIGH_NIBBLE).zero?
          length += binary[index] * 128
          index += 1
        end
        length += binary[index] - 0x80
        index += 1
        [length, index]
      end

      def parse_hash(binary)
        last_key = binary[0]
        index = 1
        result = {}

        loop do
          (value, index) = branch_parser(binary, index)
          # ordering might be lost here
          result[last_key] = value
          index += 2 if binary[index..index + 1] == [0x85, 0x20] # I have no idea what this fudge is for
          break unless index < binary.length

          next_key = binary[index]
          # break unless next_key == last_key + 1
          index += 1
          last_key = next_key
        end

        result
      end

      def parse_list(binary)
        (result, _index) = sequence_parser(binary, 0)
        result
      end

      def parse_decimal(binary)
        is_negative_exponent = binary[0] & 0xC0 == 0xC0
        exponent = (binary[0] & 0x3F) * (is_negative_exponent ? -1 : 1)
        return 0 if binary[1].blank?

        coefficient = parse_int(binary[1..])
        (10**exponent) * coefficient
      end

      def parse_timestamp(binary)
        # offset = binary[0] & LOW_NIBBLE # TODO: apply timezone
        year = (binary[1] * 128) + (binary[2] & 0x7F)
        month = binary[3] & 0x7F
        day = binary[4] & 0x7F
        hour = binary[5] & 0x7F
        minutes = binary[6] & 0x7F
        seconds = binary[7] & 0x7F
        fractional_seconds = 0.0

        if binary.length > 8
          is_negative_exponent = binary[8] & 0xC0 == 0xC0
          exponent = (binary[8] & 0x3F) * (is_negative_exponent ? -1 : 1)
          exponent = 0 if exponent.positive?
          coefficient = binary.length > 9 ? parse_int(binary[9..]) : 0
          fractional_seconds = (10**exponent) * coefficient
        end

        Time.new(year, month, day, hour, minutes, seconds + fractional_seconds, "+0000")
      end

      def parse_int(binary)
        is_negative_exponent = binary[0] & 0x80 == 0x80
        value = binary[0] & 0x7F
        binary[1..].each do |b|
          value <<= 8
          value += b
        end
        value * (is_negative_exponent ? -1 : 1)
      end

      def parse_uint(binary)
        value = 0
        binary.each do |b|
          value <<= 8
          value += b
        end
        value
      end
    end
  end
end
# rubocop:enable Metrics/*
