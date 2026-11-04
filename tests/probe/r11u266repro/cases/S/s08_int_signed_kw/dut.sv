// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int signed P = 12'shFFF;
  assign o = P;
endmodule
