// The package's own function body references the package parameter; ANOTHER
// package imported at $unit carries the same name with a different value.
package pv17a;
  parameter int COMMON = 100;
endpackage
package pv17b;
  parameter int COMMON = 200;
  parameter int LOCAL_B = 5;
  function automatic int fb();
    return COMMON + LOCAL_B;
  endfunction
endpackage
import pv17a::*;
module top_v17;
  int z;
  initial z = pv17b::fb() + COMMON;
endmodule
