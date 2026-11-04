// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module top ();
  C#(longint) a = new;
  C#(longint) b = a;
endmodule
