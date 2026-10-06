// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 4'sh3;
  localparam int Q = P + 1;
  assign o = Q;
endmodule
