// § derivedClassFullNameOrder422
// a base in a package, derived classes in a module, a package and $unit
package p;
  class B; int x; endclass
  class Z extends B; endclass
endpackage
class A extends p::B; endclass
module m;
  class M extends p::B; endclass
  M h = new;
endmodule
module top;
  A a = new;
  p::Z z = new;
  m u();
endmodule
