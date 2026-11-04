// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int A[3] = '{1, 2, 3};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic [1:0] sel, output int o);
  assign o = A[sel];
endmodule
