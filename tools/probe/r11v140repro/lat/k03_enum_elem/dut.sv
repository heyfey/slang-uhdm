// § impLhsCloneArrayTsOwnCopy140
package pk;
  typedef enum logic [1:0] {X0, X1, X2} e_t;
  parameter e_t A[2] = '{X1, X2};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output logic [1:0] o);
  assign o = A[sel];
endmodule
