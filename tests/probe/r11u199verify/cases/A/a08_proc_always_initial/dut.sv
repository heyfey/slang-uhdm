// § procPsBoundOwner192 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 4;
endpackage
module sub import p::*; (input logic clk, input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  logic [31:0] m [4];
  always_ff @(posedge clk) y1 <= {x[31:W], x[W-1:0]};
  always @(*) begin
    y2 = '0;
    y2[W:0] = m[1][W:0];
  end
  initial begin
    m[0] = '0;
    m[0][W:0] = x[W:0];
    y3 = m[2][31:W];
  end
endmodule
module top (input logic clk, input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  sub u (.*);
endmodule
