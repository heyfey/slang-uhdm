// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int A[3] = '{1, 2, 3};
endpackage
module dut #(parameter int W = 1) (input logic [1:0] sel, output int o);
  import pk::*;
  assign o = A[sel];
endmodule
