// § clsPropSpecFullNameLazy470 (a derived class of the same specialization beside the property)
package p;
  class res #(type T = int);
    T v;
  endclass
  class ir extends res #(int);
  endclass
endpackage
import p::*;
class C;
  res#(int) pr;
endclass
module top;
endmodule
