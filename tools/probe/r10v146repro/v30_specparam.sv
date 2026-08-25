// A SPECPARAM and a net-declaration expression sharing the imported name.
package pv30;
  parameter int DEL = 30;
endpackage
import pv30::*;
module top_v30;
  logic a, b;
  specify
    specparam DEL2 = 3;
  endspecify
  wire c = a & b;
  int z;
  initial z = DEL;
endmodule
