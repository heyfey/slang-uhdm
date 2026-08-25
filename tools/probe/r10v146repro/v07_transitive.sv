// pkg A has X; pkg B imports A at PACKAGE scope and declares Y; $unit imports B only.
package pv7a;
  parameter int XX = 41;
endpackage
package pv7b;
  import pv7a::*;
  parameter int YY = 42;
  function automatic int fb(); return YY + XX; endfunction
endpackage
import pv7b::*;
module top_v7;
  int z;
  initial z = YY;
endmodule
