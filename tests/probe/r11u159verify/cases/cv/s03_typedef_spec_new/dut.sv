// § classVarInitSpan152
class C #(type T = int);
  T x;
endclass
module top ();
  typedef C#(shortint) ct;
  ct c1 = new;
endmodule
