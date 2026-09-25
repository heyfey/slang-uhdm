// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int unsigned U[2] = '{5, 7};
endpackage
module dut import pk::*; #(parameter int W = 1) (output int unsigned o);
  localparam int unsigned L = U[1];
  assign o = L;
endmodule
