// § specArgTypedefNameShares468
class C #(type T = int, type U = int);
  T m;
endclass
class E; int k; endclass
class D;
  typedef E e_t;
  typedef e_t f_t;
  C #(int, f_t) x;
endclass
module top; D d; endmodule
