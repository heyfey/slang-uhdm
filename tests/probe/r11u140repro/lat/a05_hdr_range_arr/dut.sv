// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter logic [3:0] A[0:1] = '{4'h1, 4'h2};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output logic [3:0] o);
  assign o = A[sel];
endmodule
