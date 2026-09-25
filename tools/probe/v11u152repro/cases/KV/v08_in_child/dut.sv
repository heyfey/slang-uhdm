// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module child ();
  C#(int) h = new;
endmodule
module top ();
  child u();
endmodule
