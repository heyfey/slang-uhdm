// § regTdArrElabIsNet251 (package reg typedef imported at $unit, used bare in a module)
package p;
  typedef reg r_t [3];
endpackage
import p::*;
module top;
  r_t m;
endmodule
