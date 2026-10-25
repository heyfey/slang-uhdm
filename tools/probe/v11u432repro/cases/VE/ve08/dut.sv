// § pkgVarEnumBaseRefName432
package A;
enum {Z0, Z1} X;
endpackage
import A::*;
interface ifc;
endinterface
module sub;
endmodule
module top;
  sub u();
  ifc i();
endmodule
