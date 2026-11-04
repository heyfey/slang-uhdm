// § paramValRhsSharesParamConst273
module sub #(parameter int unsigned M = 5) (output logic [31:0] o2 [2]);
  assign o2[0] = M;
  assign o2[1] = '0;
endmodule
module dut (output logic [31:0] a [2], output logic [31:0] b [2]);
  sub #(.M(9)) u0(.o2(a));
  sub u1(.o2(b));
endmodule
