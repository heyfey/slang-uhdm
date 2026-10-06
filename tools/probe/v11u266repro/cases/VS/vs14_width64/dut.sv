// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o, output logic [31:0] p);
  localparam int P = 64'sh0000_0000_0000_0011;
  localparam int Q = 33'sh1_0000_0001;
  assign o = P;
  assign p = Q;
endmodule
