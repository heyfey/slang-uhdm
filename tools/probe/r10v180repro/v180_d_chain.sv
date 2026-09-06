// r10v180 arm D — THE IMPORT GRAPH.  A imports B imports C, so C's subroutine
// is cloned into B and B's listing (its own AND its clone of C's) is cloned
// into A: a CLONE OF A CLONE.  Plus a diamond and a shadowed spelling.
package Chn_c;
  typedef logic [5:0] pebble_t;
  function automatic int unsigned pebble_c(pebble_t g);
    pebble_t s;
    s = g;
    begin
      pebble_t inner;
      inner = pebble_t'(s + 1);
      s = inner;
    end
    return int'(s);
  endfunction
endpackage
package Chn_b;
  import Chn_c::*;
  typedef bit [3:0] shard_t;
  function automatic int unsigned shard_b(shard_t g);
    shard_t s;
    s = g;
    begin
      shard_t inner;
      pebble_t borrowed;      // C's typedef, seen through B's wildcard import
      inner = shard_t'(s + 1);
      borrowed = pebble_t'(6'h3f);
      s = shard_t'(int'(inner) + int'(borrowed[3:0]));
    end
    return int'(s) + pebble_c(pebble_t'(s));
  endfunction
endpackage
package Chn_a;
  import Chn_b::*;
endpackage
// diamond: D1 and D2 both wildcard-import C, E imports both
package Chn_d1; import Chn_c::*; endpackage
package Chn_d2; import Chn_c::*; endpackage
package Chn_e;  import Chn_d1::*; import Chn_d2::*; endpackage
// a SHADOW: the same identifier declared in an unrelated package
package Chn_shadow;
  typedef logic [15:0] pebble_t;
  function automatic int unsigned pebble_c(pebble_t g);
    pebble_t s;
    s = g;
    begin
      pebble_t inner;
      inner = pebble_t'(s);
      s = inner;
    end
    return int'(s);
  endfunction
endpackage
module Chn_top;
  import Chn_b::*;
  shard_t k;
  int unsigned r;
  initial begin
    k = 4'h9;
    r = shard_b(k) + Chn_shadow::pebble_c(16'h1234);
  end
endmodule
