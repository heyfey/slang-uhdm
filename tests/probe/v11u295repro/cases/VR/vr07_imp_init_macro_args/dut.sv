// § rawEndLineModel295
`define ADD(x,y) (x+y)
package p;
  logic [7:0] v = `ADD(8'd1,8'd2);
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
