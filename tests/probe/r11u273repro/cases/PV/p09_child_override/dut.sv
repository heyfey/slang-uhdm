// § paramValRhsSharesParamConst273
module m #(parameter int unsigned M = 5) (output logic [31:0] o2 [2]);
  assign o2[0] = M;
endmodule
module dut (output logic [31:0] a [2], output logic [31:0] b [2]);
  m u0(.o2(a));
  m #(.M(9)) u1(.o2(b));
endmodule
