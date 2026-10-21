// § derivedNestedBareKey422v
// a nested class with a lowercase name and a $unit class both extend a package base
package p;
  class B; endclass
endpackage
class A extends p::B;
  class zed extends p::B; endclass
  zed z = new;
endclass
class Y extends p::B; endclass
module top;
  A a = new; Y y = new;
endmodule
