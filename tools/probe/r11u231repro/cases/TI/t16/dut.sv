// § topPkgTdInstanceTop231 — a class extending a class of another package, typedef alias through the base
package pb;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class base;
    extern virtual function void set(b_t v);
  endclass
  function void base::set(b_t v);
  endfunction
endpackage
package pd;
  import pb::*;
  class der extends base;
    extern virtual function void set(b_t v);
  endclass
  function void der::set(b_t v);
  endfunction
endpackage
module top;
endmodule
