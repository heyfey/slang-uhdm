// § derivedClassFullNameOrder422
package p;
  class B #(type T = int); endclass
  class Z extends B; endclass
endpackage
import p::*;
class A extends B #(bit); endclass
module top; A a; endmodule
