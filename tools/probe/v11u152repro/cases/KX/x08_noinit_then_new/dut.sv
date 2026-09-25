// § classVarInitSpan152
class C;
  int x;
  static function C make();
    C r = new;
    return r;
  endfunction
endclass
module top ();
  C c0, c1 = new;
endmodule
