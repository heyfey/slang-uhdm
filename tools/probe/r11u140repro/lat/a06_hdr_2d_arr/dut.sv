// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int A[2][2] = '{'{1, 2}, '{3, 4}};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output int o);
  assign o = A[sel][0];
endmodule
