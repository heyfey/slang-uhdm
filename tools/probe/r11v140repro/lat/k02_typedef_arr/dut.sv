// § impLhsCloneArrayTsOwnCopy140
package pk;
  typedef int arr_t[2];
  parameter arr_t A = '{1, 2};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output int o);
  assign o = A[sel];
endmodule
