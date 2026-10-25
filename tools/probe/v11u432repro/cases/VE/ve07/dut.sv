// § pkgVarEnumBaseRefName432
package A;
enum {V0, V1} X;
enum {W0, W1} Y;
endpackage
module top;
  import A::*;
  initial X = V1;
endmodule
