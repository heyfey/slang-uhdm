// § derivedClassFullNameOrder422
package p;
  class B; endclass
  class Z extends B; endclass
endpackage
class A extends p::B; endclass
module top; A a; endmodule
