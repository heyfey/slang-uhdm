// § specArgTypedefNameShares468
package p;
  class E; int k; endclass
  typedef E e_t;
endpackage
import p::*;
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  C #(int, e_t) x;
endclass
module top; D d; endmodule
