// § elabBasedLitLowerBase427
module top(input logic [7:0] a, output logic [7:0] o, output logic [7:0] q);
  localparam B = 8'B1010_xx01;
  localparam H = 'HAB;
  assign o = a & B;
  assign q = a | H;
endmodule
