// § specArgTypedefNameShares468
// the scoreboard shape: a parameterized class's typedef of its own specialization as the argument
class C #(type T = int, type U = int);
  T m;
endclass
class D #(type P = int);
  typedef D #(P) this_type;
  C #(P, this_type) x;
endclass
module top; D #(byte) d; endmodule
