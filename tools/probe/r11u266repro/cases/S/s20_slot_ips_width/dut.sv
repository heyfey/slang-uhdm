// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 4'sh3;
  assign o = x[0 +: P];
endmodule
