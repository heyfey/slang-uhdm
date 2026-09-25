// § classVarInitNewDecl152v
class C #(type T=int);
  T x;
endclass
module top ();
  typedef C#(int) ct;
  ct c1 = null;
  ct c2 = new;
endmodule
