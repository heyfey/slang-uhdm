// § classVarInitNewDecl152v
class C;
  int x;
endclass
class D extends C;
endclass
module top ();
  C c0 = new;
  C c1 = new (c0);
endmodule
