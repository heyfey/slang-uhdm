// v201 arm F — a CROSS-PACKAGE qualified reference, and a package that
// imports another and re-exports the materialized copy.
package p201vf1;
  parameter F_A = 13;
  parameter int F_T = 9;
endpackage
package p201vf2;
  import p201vf1::*;
  parameter F_B = p201vf1::F_A;
  parameter F_C = F_A;
  parameter F_D = p201vf1::F_T;
endpackage
import p201vf2::*;
module m201vf;
endmodule
