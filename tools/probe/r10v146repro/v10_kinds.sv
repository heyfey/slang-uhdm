// Parameter KINDS in a $unit-imported package: written type / string / real /
// unsized literal / expression of other package params / localparam / type param.
package pv10;
  parameter int          P_INT   = 12;
  parameter logic [5:0]  P_TYPED = 6'h2a;
  parameter string       P_STR   = "abc";
  parameter real         P_REAL  = 2.5;
  parameter              P_UNS   = 'h1f;
  parameter int          P_EXPR  = P_INT * 2 + 1;
  localparam int         P_LOC   = 77;
  parameter type         P_TYPE  = logic [3:0];
endpackage
import pv10::*;
module top_v10;
  logic [5:0] a;
  P_TYPE      t;
  int         e;
  real        r;
  string      s;
  assign a = P_TYPED;
  initial begin
    e = P_EXPR + P_INT + P_LOC + P_UNS;
    r = P_REAL;
    s = P_STR;
    t = 4'h3;
  end
endmodule
