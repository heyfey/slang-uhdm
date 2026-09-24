// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int N = 3;
  parameter int A[0:N-1] = '{7, 8, 9};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic [1:0] sel, output int o);
  assign o = A[sel];
endmodule
