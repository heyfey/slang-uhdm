// § topPkgTdInstanceTop231 — alias depth 2 on an extern method formal
package p;
  typedef enum logic [1:0] {A0, A1, A2} a_e;
  typedef a_e b_t;
  typedef b_t c_t;
  class c;
    extern function void set(c_t v);
    extern function c_t get();
  endclass
  function void c::set(c_t v);
  endfunction
  function c_t c::get();
    return A1;
  endfunction
endpackage
module top;
endmodule
