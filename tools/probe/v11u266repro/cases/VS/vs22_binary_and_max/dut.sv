// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o, output logic [31:0] p);
  localparam int P = 8'sb0111_1111;
  localparam int Q = 32'sd2147483647;
  assign o = P;
  assign p = Q;
endmodule
