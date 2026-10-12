// § rawEndLineModel295
`define S(x) `"x`"
package p;
  string v = `S(ab);
endpackage
module top(output logic o);
  import p::*;
  assign o = (v == "ab");
endmodule
