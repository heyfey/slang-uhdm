// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 6;
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [7:0] y3 [2]);
  assign y1[W:0] = x[6:0];
  assign y1[31:W+1] = '0;
  assign y2[31:W] = {x[25:0]};
  assign y2[W-1:0] = x[W-1:0];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y3[i][W:0] = x[i+:7];
    assign y3[i][7] = 1'b0;
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [7:0] y3 [2]);
  sub u (.*);
endmodule
