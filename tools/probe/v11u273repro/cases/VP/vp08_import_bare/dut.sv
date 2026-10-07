// § paramValRhsSharesParamConst273
package pk;
  localparam int unsigned M = 123;
endpackage
module dut (output logic [31:0] o2 [2]);
  import pk::*;
  assign o2[0] = M;
  assign o2[1] = pk::M;
endmodule
