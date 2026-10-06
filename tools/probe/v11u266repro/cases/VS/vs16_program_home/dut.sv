// § sgnLitElabFreshIntTs266
program pr;
  localparam int P = 8'sh05;
  int x;
  initial x = P;
endprogram
module dut (output logic [31:0] o);
  localparam int Q = 8'sh06;
  assign o = Q;
endmodule
