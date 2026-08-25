// A class inside a package, with a class-scope localparam shadowing the $unit import.
package pv6;
  parameter int CAP = 13;
endpackage
package pv6b;
  class c6;
    localparam int CAP = 3;
    function int g(); return CAP; endfunction
  endclass
endpackage
import pv6::*;
module top_v6;
  int z;
  initial z = CAP;
endmodule
