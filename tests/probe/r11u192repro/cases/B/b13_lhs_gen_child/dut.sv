// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3 [2], output logic [31:0] y4, output logic [31:0] y5, output logic [31:0] y6 [2]);
  assign y1[S:0] = x[4:0];
  assign {y2[S:0], y5[1:0]} = x[6:0];
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y3[g][S:0] = x[4:0];
    assign y6[g][S:0] = '1;
  end
  if (1) begin : gi
    assign y4[S:0] = x[4:0];
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3 [2], output logic [31:0] y4, output logic [31:0] y5, output logic [31:0] y6 [2]);
  sub u (.*);
endmodule
