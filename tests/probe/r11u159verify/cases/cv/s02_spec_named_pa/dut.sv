// § classVarInitSpan152
class C #(type T = int, int W = 4);
  T x;
endclass
module top ();
  C#(.W(8)) c1 = new;
endmodule
