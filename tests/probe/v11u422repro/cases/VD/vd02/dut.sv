// § derivedClassFullNameOrder422
// derived classes in a program and in $unit; a package named with a capital
package Q;
  class B; endclass
  class W extends B; endclass
endpackage
class A extends Q::B; endclass
class Y extends Q::B; endclass
program pr;
  class P extends Q::B; endclass
  P h = new;
endprogram
module top;
  A a = new; Y y = new; Q::W w = new;
endmodule
