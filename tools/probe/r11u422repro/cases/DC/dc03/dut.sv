// § derivedClassFullNameOrder422
package p;
  class B; endclass
  class A extends B; endclass
endpackage
class Z extends p::B; endclass
module top; Z z; endmodule
