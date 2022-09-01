package Json;

use strict;
use Exporter qw(import);
use Pre qw(try_);
use JSON::PP qw(encode_json decode_json);

our @EXPORT = qw(
  encodeJson
  decodeJson
);

*encodeJson = try_ \&encode_json;
*decodeJson = try_ \&decode_json;

1;
