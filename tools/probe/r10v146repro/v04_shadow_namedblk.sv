// $unit wildcard import; a named begin inside an always block declares the same name.
package pv4;
  parameter int LIM = 6;
endpackage
import pv4::*;
module top_v4;
  int q;
  initial begin : nb
    localparam int LIM = 1;
    q = LIM;
  end
  int r;
  initial r = LIM;
endmodule
