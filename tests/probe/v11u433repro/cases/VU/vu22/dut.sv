// § unitParamLitForm433v
localparam S1 = 'o17;
localparam S2 = 8'hA_5;
localparam S3 = 'b1_01;
localparam S4 = 12'o7_7;
localparam S5 = 8'HFF;
localparam S6 = 4'B1010;
localparam S7 = 6'O17;
module c(input [63:0] a); endmodule
module top;
  logic [63:0] x;
  c u1(.a(x + S1)); c u2(.a(x + S2)); c u3(.a(x + S3)); c u4(.a(x + S4));
  c u5(.a(x + S5)); c u6(.a(x + S6)); c u7(.a(x + S7));
endmodule
