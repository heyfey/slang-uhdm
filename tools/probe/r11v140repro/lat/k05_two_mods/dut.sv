// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int A[2] = '{4, 5};
endpackage
module d1 import pk::*; #(parameter int W = 1) (output int o); assign o = A[0]; endmodule
module d2 import pk::*; #(parameter int W = 2) (output int o); assign o = A[1]; endmodule
module top(output int o1, output int o2); d1 u1(.o(o1)); d2 u2(.o(o2)); endmodule
