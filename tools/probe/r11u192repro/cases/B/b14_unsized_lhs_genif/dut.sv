// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  assign y1[S:0] = '1;
  assign y2 = x[S:0] | '0;
  if (1) begin : gi
    assign y4[S:0] = '1;
    assign y3 = x[S:0] | '0;
    assign y5 = {{S{1'b0}}, x[27:0]} | '0;
  end
endmodule
