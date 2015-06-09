# FFXCodec

Encodes two unsigned integers into a single, larger (32 or 64-bit) integer.

Optionally, it can encrypt/decrypt the resulting integer using a home-built implementation of the AES-FFX format-preserving cipher.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ffxcodec'
```

## Usage

Example (without encryption):

        ffx = FFXCodec.new(40, 24)       # left: 40-bit int, right: 24-bit int
        ffx.encode(7183940, 99)          #=> 5084490834151041050
        ffx.decode(5084490834151041050)  #=> [7183940, 99]

Example (with encryption):

        ffx = FFXCodec.new(40, 24)
        ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "8675309")
        ffx.encode(7183940, 99)          #=> 120526513111139
        ffx.decode(5084490834151041050)  #=> [7183940, 99]
