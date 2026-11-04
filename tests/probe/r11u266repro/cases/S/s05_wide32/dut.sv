// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 32'sh8000_0000;
  assign o = P;
endmodule
