// § derivedClassFullNameOrder422
package q;
  class B; endclass
endpackage
package p;
  class Z extends q::B; endclass
endpackage
package a;
  class Y extends q::B; endclass
endpackage
class A extends q::B; endclass
module top; A a; endmodule
