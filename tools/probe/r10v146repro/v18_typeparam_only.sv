// A $unit-imported package whose ONLY parameter is a TYPE parameter.
package pv18;
  parameter type TT = logic [6:0];
  typedef TT tt_t;
endpackage
import pv18::*;
module top_v18;
  tt_t a;
  TT   b;
  assign a = 7'h11;
  assign b = a;
endmodule
