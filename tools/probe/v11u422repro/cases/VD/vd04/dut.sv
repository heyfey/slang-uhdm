// § derivedClassFullNameOrder422
// a chain: two levels of derived classes across $unit and two packages
package a;
  class B; endclass
endpackage
package b;
  import a::*;
  class D extends B; endclass
  class E extends D; endclass
endpackage
class F extends b::D; endclass
class G extends a::B; endclass
module top;
  F f = new; G g = new; b::E e = new;
endmodule
