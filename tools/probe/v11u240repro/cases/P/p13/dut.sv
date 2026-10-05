// § hoistPoolSourceOrder240: named-argument calls (linked and unlinked), super and this paths, a class-scoped static call
package hp;
  function automatic int f2(int a, int b = 2);
    return a + b;
  endfunction
  class bse;
    int g;
    static function int sf(int v);
      return v;
    endfunction
  endclass
  class zd extends bse;
    int h;
    extern function int m1();
  endclass
  class ad extends bse;
    int h;
    extern function int m2();
  endclass
  function int ad::m2();
    return f2(.a(h)) + this.g + super.g;
  endfunction
  function int zd::m1();
    return f2(.b(g), .a(h)) + bse::sf(h);
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
