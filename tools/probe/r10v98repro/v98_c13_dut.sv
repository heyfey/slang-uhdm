// v98_c13 — every REFERENCE SHAPE of the inherited bare name.
package p13v;
  class payload13v; int f; endclass
  class other13v;   int g; endclass
  class a13win98v;
    typedef bit [13:0] rs13_t;
    typedef payload13v ch13_t;
  endclass
  class m13base98v;
    typedef int      rs13_t;
    typedef other13v ch13_t;
    static rs13_t s_base;
    function void own(rs13_t x); endfunction
  endclass
  class z13der98v extends m13base98v;
    rs13_t prop;                                  // PROPERTY
    static rs13_t sprop;                          // STATIC property
    ch13_t hprop;                                 // class-handle PROPERTY
    function void f_formal(rs13_t x); endfunction // FORMAL
    function void f_out(output rs13_t x); x = 0; endfunction
    function void f_ref(ref rs13_t x); endfunction
    function void f_dflt(rs13_t x = 0); endfunction
    function rs13_t f_ret(); return 0; endfunction        // RETURN
    function ch13_t f_hret(); return null; endfunction    // class-handle RETURN
    function void f_loc(); rs13_t l; l = 0; endfunction   // LOCAL
    function void f_cast(int v); rs13_t t; void'($cast(t, v)); endfunction
    function void f_new(); ch13_t h; h = new(); endfunction // new() through the td
    function void f_bits(); int n; n = $bits(rs13_t); endfunction
  endclass
  class z14par98v #(type T = int); T v; endclass
  class z15use98v extends m13base98v;
    z14par98v#(rs13_t) g;                         // #() PARAM written as the td
    function void mk(); g = new(); endfunction
  endclass
endpackage
module top13v;
  import p13v::*;
  z13der98v z; z15use98v y;
  initial begin z = new(); y = new(); end
endmodule
