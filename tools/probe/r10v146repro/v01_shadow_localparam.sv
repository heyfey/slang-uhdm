// $unit wildcard import; the MODULE declares its own localparam of the SAME name.
// Legal SV: a local declaration shadows a wildcard import.
package pv1;
  parameter int WID = 8;
  parameter int OTH = 5;
endpackage
import pv1::*;
module top_v1;
  localparam int WID = 3;
  logic [7:0] a;
  assign a = WID + OTH;
endmodule
