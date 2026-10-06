// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 12'hFFF;
  assign o = P;
endmodule
