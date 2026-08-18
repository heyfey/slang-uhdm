// vbuvm13 arm a6 — the axes the brief names that a1..a5 do not carry: a default
// naming a CLASS PROPERTY (in-body and out-of-body), a STATIC class property, a
// DPI-C import prototype WITH a default, and an out-of-body STATIC method.
package pp6;
  int gp6 = 5;
  class cp6;
    int prop6 = 1;
    static int sprop6 = 2;
    localparam int LP6 = 3;
    function int m_prop(int a, int b = prop6);          return a+b; endfunction
    function int m_sprop(int a, int b = sprop6);        return a+b; endfunction
    function int m_lp(int a, int b = LP6);              return a+b; endfunction
    extern function int x_prop(int a, int b = prop6);
    extern function int x_sprop(int a, int b = sprop6);
    extern static function int x_stat(int a, int b = sprop6);
  endclass
  function int cp6::x_prop(int a, int b = prop6);       return a+b; endfunction
  function int cp6::x_sprop(int a, int b = sprop6);     return a+b; endfunction
  function int cp6::x_stat(int a, int b = sprop6);      return a+b; endfunction
  // a DPI-C import prototype WITH a default value naming an earlier formal
  import "DPI-C" function int dpi6(input int a, input int b);
endpackage

module m_a6;
  import pp6::*;
  cp6 h;
  int z;
  initial begin
    h = new();
    z = h.m_prop(1); z = h.m_sprop(1); z = h.m_lp(1);
    z = h.x_prop(1); z = h.x_sprop(1); z = cp6::x_stat(1);
    z = dpi6(1,2);
  end
endmodule
