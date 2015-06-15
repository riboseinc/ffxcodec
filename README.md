# FFXCodec

Encodes two unsigned integers into a single, larger (32 or 64-bit) integer.

Optionally, it can encrypt/decrypt the resulting integer using a home-built implementation of the AES-FFX format-preserving cipher.


## Usage

Start by divvying up the 32 or 64 bits that will make up the resulting integer:

    ffx = FFXCodec.new(32, 32)  # divide 64-bit int equally
    ffx = FFXCodec.new(8, 24)   # divide 32-bit int 8 bits left, 24-bits right

Then, encode and decode accordingly:

    ffx.encode(1234567890, 4)          #=> 20712612157194244
    ffx.decode(20712612157194244)      #=> [1234567890, 4]

Optionally, you can enable encryption by setting a `key` and `tweak`:

    ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
    ffx.encode(797980150281, 5427652)  #=> 354718250089538754
    ffx.decode(354718250089538754)     #=> [797980150281, 5427652]


### Putting it all together

Example **without encryption** (40 and 24-bit integers into 64-bit):

    ffx = FFXCodec.new(40, 24)
    ffx.encode(1234567890, 4)          #=> 20712612157194244
    ffx.decode(20712612157194244)      #=> [1234567890, 4]

Example **with encryption** (40 and 24-bit integers into 64-bit):

    ffx = FFXCodec.new(40, 24)
    ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
    ffx.encode(797980150281, 5427652)  #=> 354718250089538754
    ffx.decode(354718250089538754)     #=> [797980150281, 5427652]


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ffxcodec'
```


## FAQ

Q. Does this only work with unsigned integers?
A. It could be made to work with signed integers, but it wasn't built or tested with that use case in mind.


## Warning

The AES-FFX implementation is experimental.  It was cooked up for this proof of concept.
The tests included are based on the NIST reference, but only a handful have been implemented.
Additionally, FFX is still a DRAFT specification.  Thus, it cannot yet be considered cryptographically secure.
Don't use this for anything beyond basic obfuscation.
