// § specArgTypedefNameShares468
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  typedef C #(byte) cb_t;
  C #(int, cb_t) x;
endclass
module top; D d; endmodule
