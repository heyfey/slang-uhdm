// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o, output logic [31:0] p);
  localparam int P = 'sh7F;
  localparam int Q = 8'SH7F;
  assign o = P;
  assign p = Q;
endmodule
