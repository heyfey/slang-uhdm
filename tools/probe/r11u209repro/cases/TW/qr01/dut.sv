// § twinElemOnlyNoRange209: a dynamic-array and an associative typedef returned by class methods, and a queue of a struct (copied from r11u196repro/cases/V191/qr01)
package p;
  typedef struct { int a; } s_t;
  class c;
    typedef int d_t[];
    typedef int a_t[string];
    typedef s_t q_t[$];
    function d_t gd(); d_t r; return r; endfunction
    function a_t ga(); a_t r; return r; endfunction
    function q_t gq(); q_t r; return r; endfunction
  endclass
endpackage
module top;
  p::c h;
endmodule
