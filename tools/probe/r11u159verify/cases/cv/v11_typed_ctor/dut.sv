// § classVarInitNewDecl152v
class C;
  int x;
endclass
class D extends C;
endclass
module top ();
  C c1 = D::new;
endmodule
