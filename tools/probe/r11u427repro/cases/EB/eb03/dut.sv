// § sgnBinElabIntBranchStands427
module top(input logic [7:0] a, output logic [7:0] o, output logic [7:0] q);
  localparam D = 4'sb1010;
  localparam E = 8'SB1000_0001;
  assign o = a + D;
  assign q = E;
endmodule
