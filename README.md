# FFXCodec

Encodes two unsigned integers into a single, larger (32 or 64-bit) integer.

Optionally, it can encrypt/decrypt the resulting integer using a home-built implementation of the AES-FFX format-preserving cipher.

## Usage

Start by divvying up the 32 or 64 bits that will make up the resulting integer:

    ffx = FFXCodec.new(32, 32)  # divide 64-bit int equally
    ffx = FFXCodec.new(8, 24)   # divide 32-bit int 8 bits left, 24 bits right

Optionally, you can then enable encryption by setting a `key` and `tweak`:

    ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "8675309")

Then, encode and decode accordingly.

### Putting it all together

Example (without encryption):

    ffx = FFXCodec.new(40, 24)       # left: 40-bit int, right: 24-bit int
    ffx.encode(7183940, 99)          #=> 5084490834151041050
    ffx.decode(5084490834151041050)  #=> [7183940, 99]

Example (with encryption):

    ffx = FFXCodec.new(40, 24)
    ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "8675309")
    ffx.encode(7183940, 99)          #=> 120526513111139
    ffx.decode(5084490834151041050)  #=> [7183940, 99]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ffxcodec'
```

## Warning

The AES-FFX implementation was cooked up for this proof of concept. It shouldn't be considered secure.
