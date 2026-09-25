// § classVarInitNewDecl152v
class C;
  int x;
  static function C make();
    C r = new;
    return r;
  endfunction
endclass
module top ();
  C c1 = new;
  C c2 = null;
endmodule
