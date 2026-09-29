// § unitImportCopyOwnTsRef214 § unitImportCopyValueFollowsPkg214 — two $unit wildcard imports, the second package's parameters built from the first's
package p;
  parameter int A = 7;
  parameter B = A << 2;
endpackage
package q;
  parameter int C = p::A + 1;
  parameter D = p::B * C - 3;
endpackage
import p::*;
import q::*;
module top(output int o);
  assign o = A + B + C + D;
endmodule
