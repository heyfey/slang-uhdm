// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter logic [7:0] A[3] = '{8'h1, 8'h2, 8'h3};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic [1:0] sel, output logic [7:0] o);
  assign o = A[sel];
endmodule
