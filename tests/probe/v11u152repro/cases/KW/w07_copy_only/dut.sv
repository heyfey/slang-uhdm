// § classVarInitNewDecl152v
class C;
  int x;
endclass
module top ();
  C c1;
  C c2 = c1;
endmodule
