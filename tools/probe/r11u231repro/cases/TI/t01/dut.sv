// § topPkgTdInstanceTop231 — extern method formal of an alias-of-enum typedef (pass 225's x1)
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
endmodule
