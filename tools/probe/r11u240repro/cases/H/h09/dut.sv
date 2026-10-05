// § hoistPoolSourceOrder240: an enum constant of the class scope and a with-iterator in out-of-body bodies
package hp;
  class zb;
    typedef enum {RED, BLUE} col_t;
    col_t c;
    int q[$];
    extern function bit is_red();
    extern function int cnt();
  endclass
  function bit zb::is_red();
    return c == RED;
  endfunction
  function int zb::cnt();
    int r[$];
    r = q.find with (item > 2);
    return r.size();
  endfunction
  class aa;
    typedef enum {RED, GREEN} k_t;
    k_t c;
    extern function bit is_red();
  endclass
  function bit aa::is_red();
    return c == RED;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
