// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
`define W S
module sub (input logic [4:0] a, output logic [4:0] b);
  assign b = a;
endmodule
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, y2, y3, output logic [4:0] y4);
  assign y1 = x[`W:0];
  assign y2 = {1'b0, x[`W:0]};
  if (1) begin : gi
    assign y3 = {x[31:S]};
  end
  sub u (.a(x[S:0]), .b(y4));
endmodule
