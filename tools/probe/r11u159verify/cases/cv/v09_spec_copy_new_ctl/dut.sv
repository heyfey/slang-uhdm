// § classVarInitNewDecl152v
class C #(type T = int);
  T x;
endclass
module top ();
  C#(int) c0 = new;
  C#(int) c1 = new c0;
endmodule
