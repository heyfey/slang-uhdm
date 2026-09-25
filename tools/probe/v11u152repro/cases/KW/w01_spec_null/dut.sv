// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module top ();
  C#(longint) c1 = null;
endmodule
