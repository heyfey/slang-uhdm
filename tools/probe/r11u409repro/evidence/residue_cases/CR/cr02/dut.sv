// residue (no law landed): a read of an imported package parameter folded in a cont_assign; see README
package p;
  parameter int A = 5;
endpackage
import p::*;
module top;
  int x;
  assign x = A;
endmodule
