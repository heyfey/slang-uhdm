// pkg A imported at $unit; pkg B declares its OWN parameter of the same name and
// uses it in its own function body (the shape the law's re-point targets).
package pva;
  parameter int SHARED = 11;
endpackage
package pvb;
  parameter int SHARED = 22;
  function automatic int fb();
    return SHARED;
  endfunction
endpackage
import pva::*;
module top_v5;
  int z;
  initial z = pvb::fb() + SHARED;
endmodule
