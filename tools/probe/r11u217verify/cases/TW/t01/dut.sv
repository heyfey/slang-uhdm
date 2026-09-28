// § twinElemOnlyNoRange209 — r11u217 t01: class methods returning dynamic, associative and queue typedefs of an enum, a class handle, a string and a packed struct element
package p;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { logic [3:0] a; } ps_t;
  class k; int v; endclass
  class c;
    typedef e_t de_t[];
    typedef k ak_t[int];
    typedef string qs_t[$];
    typedef ps_t qp_t[$];
    typedef e_t ae_t[string];
    function de_t f1(); de_t r; return r; endfunction
    function ak_t f2(); ak_t r; return r; endfunction
    function qs_t f3(); qs_t r; return r; endfunction
    function qp_t f4(); qp_t r; return r; endfunction
    function ae_t f5(); ae_t r; return r; endfunction
  endclass
endpackage
module top;
  p::c h;
endmodule
