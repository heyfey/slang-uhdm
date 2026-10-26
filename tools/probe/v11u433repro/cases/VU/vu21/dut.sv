// § unitParamPlainEval433v
localparam S1 = 2*3;
localparam S2 = 7/2;
localparam S3 = -(2);
localparam S4 = 10-3;
localparam S5 = 1<<4;
localparam S6 = (2+3)*2;
localparam S7 = 4294967296;
localparam S8 = 3000000000 + 1;
localparam S9 = 2 > 1;
localparam S10 = 2147483647;
localparam S11 = 2147483648;
localparam S12 = 1_000;
module c(input [63:0] a); endmodule
module top;
  logic [63:0] x;
  c u1(.a(x + S1)); c u2(.a(x + S2)); c u3(.a(x + S3)); c u4(.a(x + S4));
  c u5(.a(x + S5)); c u6(.a(x + S6)); c u7(.a(x + S7)); c u8(.a(x + S8));
  c u9(.a(x + S9)); c u10(.a(x + S10)); c u11(.a(x + S11)); c u12(.a(x + S12));
endmodule
