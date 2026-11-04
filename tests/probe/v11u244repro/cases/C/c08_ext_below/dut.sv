// § methCallNameSpanAcrossLines244
package p;
  virtual class cb_t;
    extern function int get(int a = 1);
    pure virtual function void z();
  endclass
  function int cb_t::get(int a = 1); return a; endfunction
endpackage
package p2;
  import p::*;
  class user;
    function int run(cb_t c);
      return c .get() + c.
             get(.a(2)) + later_f(c);
    endfunction
    function int later_f(cb_t c); return c. get(); endfunction
  endclass
endpackage
module top; p2::user u; initial u = new(); endmodule
