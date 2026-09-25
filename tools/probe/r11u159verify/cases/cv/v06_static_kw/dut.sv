// § classVarInitNewDecl152v
class C;
  int x;
  function C clone();
    C r = new;
    r.x = x;
    return r;
  endfunction
  static function C make();
    C r = new;
    return r;
  endfunction
endclass
module top ();
  static C c1 = new;
endmodule
