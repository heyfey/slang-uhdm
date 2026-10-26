// § unitParamPlainEval433v
localparam int S1 = 2*3;
localparam int S2 = 10-3;
localparam logic [7:0] S3 = 2+3;
localparam int unsigned S4 = 7/2;
localparam bit [63:0] S5 = 4294967296;
localparam int S6 = 2 > 1;
localparam shortint S7 = 5;
module c(input [63:0] a); endmodule
module top;
  logic [63:0] x;
  c u1(.a(x + S1)); c u2(.a(x + S2)); c u3(.a(x + S3)); c u4(.a(x + S4));
  c u5(.a(x + S5)); c u6(.a(x + S6)); c u7(.a(x + S7));
endmodule
