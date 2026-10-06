// § sgnLitElabFreshIntTs266
`define LIT 8'sh7F
module dut (output logic [31:0] o);
  localparam int P = `LIT;
  assign o = P;
endmodule
