// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 4'sh3;
  logic [P:0] w;
  assign w = '1;
  assign o = 64'(w);
endmodule
