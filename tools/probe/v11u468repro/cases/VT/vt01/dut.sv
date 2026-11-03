// § specArgTypedefNameShares468
class C #(type T = int, type U = int);
  T m;
endclass
class E; int k; endclass
module top;
  typedef E e_t;
  C #(int, e_t) x;
endmodule
