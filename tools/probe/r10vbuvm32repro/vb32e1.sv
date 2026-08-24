// vb32e1 — ESCAPED identifiers, a second specialization, and a class method
// LOCALLY shadowed by a same-named subroutine at the call site.
package e32;
  class \esc$cls32 ;
    static int h32;
    extern static function int \esc$fn32 (int a);
    extern static function int plain32(int a);
    typedef \esc$cls32  this_type;
    extern static function int run32();
  endclass
  function int \esc$cls32 ::\esc$fn32 (int a); h32 += a; return a; endfunction
  function int \esc$cls32 ::plain32(int a); return a; endfunction
  function int \esc$cls32 ::run32();
    int r;
    r  = \esc$cls32 ::\esc$fn32 (1);   // E1 escaped qualifier = defining class -> call
    r += this_type::\esc$fn32 (2);     // E2 this_type + escaped final id       -> ref
    r += \esc$cls32 ::plain32(3);      // E3 escaped qualifier, plain method    -> call
    r += this_type::plain32(4);        // E4                                    -> ref
    return r;
  endfunction

  class g32 #(int W = 1);
    extern static function int gf32(int a);
    typedef g32 #(W) this_type;
    extern static function int run2_32();
  endclass
  function int g32::gf32(int a); return a + W; endfunction
  function int g32::run2_32();
    int r;
    r  = g32#(1)::gf32(5);        // E5 own name + params -> call
    r += g32#(3)::gf32(6);        // E6 second specialization -> call
    r += this_type::gf32(7);      // E7 -> ref
    return r;
  endfunction
endpackage

module vb32e1;
  int r;
  initial begin
    r  = e32::\esc$cls32 ::run32();
    r += e32::g32#(1)::run2_32();
  end
endmodule
