// § classVarInitNewDecl152v
class C;
  int x;
  static function C make();
    C r = new;
    return r;
  endfunction
endclass
module top ();
  C c1 = C::make();
  C c2 = c1;
  C c3;
  initial c3 = c2;
endmodule
