// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter logic [3:0] A[2] = '{4'h1, 4'h2};
endpackage
module dut(input logic sel, output logic [3:0] o);
  import pk::*;
  assign o = A[sel];
endmodule
