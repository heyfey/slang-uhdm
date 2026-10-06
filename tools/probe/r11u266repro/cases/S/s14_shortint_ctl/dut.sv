// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam shortint P = 8'sh7;
  assign o = P;
endmodule
