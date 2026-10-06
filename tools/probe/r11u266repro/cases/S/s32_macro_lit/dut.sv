// § sgnLitElabFreshIntTs266
`define SL 12'shFFF
module dut (output logic [63:0] o);
  localparam int P = `SL;
  assign o = P;
endmodule
