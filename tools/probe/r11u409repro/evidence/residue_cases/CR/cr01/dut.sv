// residue (no law landed): a read of an imported package parameter folded in a cont_assign; see README
package p;
  parameter bit [3:0] A = 4'd5;
endpackage
import p::*;
module top;
  logic [3:0] x;
  assign x = A;
endmodule
