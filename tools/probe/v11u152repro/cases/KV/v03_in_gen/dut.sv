// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module top ();
  if (1) begin : g
    C#(longint) c1 = new;
  end
endmodule
