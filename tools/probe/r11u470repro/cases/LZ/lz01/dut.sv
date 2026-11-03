// § clsPropSpecFullNameLazy470 (a class property specialization the § 468 full-name law does not rename: the type_parameter full names stay unstored)
package p;
  class res #(type T = int);
    T v;
  endclass
endpackage
import p::*;
class C;
  res#(int) pr;
endclass
module top;
endmodule
