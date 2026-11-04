// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o);
  localparam int unsigned M = 300;
  assign w = M;
  assign o = {31'd0, w};
endmodule
