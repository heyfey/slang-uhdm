// § paramValRhsSharesParamConst273
module dut (output logic [15:0] a, output logic [15:0] b);
  localparam int unsigned M = 70000;
  assign {a, b} = M;
endmodule
