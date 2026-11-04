// § impLhsCloneArrayTsOwnCopy140
package pk;
  parameter int A[2] = '{4, 5};
endpackage
interface ifc import pk::*; #(parameter int W = 1);
  logic [A[0]-1:0] d;
endinterface
module top; ifc i(); endmodule
