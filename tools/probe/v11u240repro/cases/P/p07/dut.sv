// § hoistPoolSourceOrder240: an enum constant and a with iterator, a task calling a function, extern above and below
package hp;
  class zs;
    typedef enum {IDLE, BUSY} st_t;
    st_t st;
    int q[$];
    extern function int pick();
    extern task step();
  endclass
  task zs::step();
    st = BUSY;
    void'(pick());
  endtask
  function int zs::pick();
    int r[$];
    r = q.find with (item > 0);
    if (st == IDLE) return 0;
    return r.size();
  endfunction
  class as;
    int q[$];
    extern function int cnt();
  endclass
  function int as::cnt();
    int r[$];
    r = q.find with (item < 3);
    return r.size();
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
