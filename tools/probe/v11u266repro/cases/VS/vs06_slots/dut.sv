// § sgnLitElabFreshIntTs266
module dut (input logic [31:0] i, output logic [7:0] o, output logic [3:0] p, output logic [15:0] r);
  localparam int W = 8'sd8;
  localparam int K = 4'sh2;
  logic [W-1:0] w;
  assign w = i[W-1:0];
  assign o = w;
  assign p = i[K +: 4];
  assign r = {K{w}};
endmodule
