// § paramValRhsSharesParamConst273
module sub (output logic [31:0] o2 [2]);
  localparam int unsigned M = 4095;
  assign o2[0] = M;
  assign o2[1] = M;
endmodule
module dut (output logic [31:0] a [2], output logic [31:0] b [2]);
  sub u0(.o2(a));
  sub u1(.o2(b));
endmodule
