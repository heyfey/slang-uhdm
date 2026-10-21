// § derivedNestedBareKey422v
// two nested classes of one bare name in two outer classes, both extending a package base
package p;
  class B; endclass
endpackage
class A extends p::B;
  class N extends p::B; endclass
endclass
class C;
  class N extends p::B; endclass
endclass
module top;
  A a = new; C c = new;
endmodule
