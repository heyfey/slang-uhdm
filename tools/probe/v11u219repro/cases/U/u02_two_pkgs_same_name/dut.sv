// § unitImportCopyValueFollowsPkg214 — two $unit-imported packages declaring a parameter of the same name, only one read by name through its package
package p1;
  parameter A = 3 * 5;
  parameter B1 = 2;
endpackage
package p2;
  parameter A = 100 - 1;
  parameter B2 = 4;
endpackage
import p1::*;
import p2::B2;
module top(output int o);
  assign o = p1::A + B1 + B2;
endmodule
