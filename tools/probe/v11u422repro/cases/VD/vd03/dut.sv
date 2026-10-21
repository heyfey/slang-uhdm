// § derivedClassFullNameOrder422
// parameterized derived classes and a parameterized base
package p;
  class B #(int N = 1); int v = N; endclass
  class Z #(int K = 2) extends B #(K); endclass
endpackage
class A extends p::B #(4); endclass
class C #(type T = int) extends p::B; T t; endclass
module top;
  A a = new; p::Z #(3) z = new; C #(bit) c = new;
endmodule
