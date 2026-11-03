// § specArgTypedefNameShares468
class C #(type T = int);
  T m;
endclass
class E; int k; endclass
typedef E e_t;
class D;
  C #(e_t) x;
  C #(e_t) y;
endclass
module top; D d; endmodule
