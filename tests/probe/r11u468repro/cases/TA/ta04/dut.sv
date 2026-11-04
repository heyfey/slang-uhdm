// § specArgTypedefNameShares468
// a $unit typedef of a class as the argument of a class property specialization
class C #(type T = int, type U = int);
  T m;
endclass
class E; int e; endclass
typedef E e_t;
class D;
  C #(int, e_t) x;
endclass
module top; D d; endmodule
