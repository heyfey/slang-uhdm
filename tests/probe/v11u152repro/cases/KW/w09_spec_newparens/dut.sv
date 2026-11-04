// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module top ();
  C#(byte) c1 = new();
endmodule
