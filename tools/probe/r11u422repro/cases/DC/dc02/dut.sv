// § derivedClassFullNameOrder422
package p;
  class B; endclass
  class Z extends B; endclass
endpackage
import p::*;
class A extends B; endclass
module top; A a; endmodule
