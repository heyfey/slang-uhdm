// § hoistPoolSourceOrder240: a with iterator and an enum constant in a constructor written before a method that reads them
package hp;
  class ac;
    typedef enum {OFF, ON} m_t;
    m_t md;
    int q[$];
    int n;
    extern function new();
  endclass
  function ac::new();
    int r[$];
    r = q.find with (item > 1);
    md = ON;
    n = r.size();
  endfunction
  class zc;
    typedef enum {OFF, ON} m_t;
    m_t md;
    int q[$];
    int n;
    extern function int f();
  endclass
  function int zc::f();
    int r[$];
    r = q.find with (item < 1);
    md = OFF;
    return n + r.size();
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
