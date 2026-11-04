// § cloneAggTsAtHomeListing241
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef enum logic [1:0] { A0, A1 } e_t;
  class pr;
    extern function int fmt(s_t row);
    extern function int f2(s_t row2, e_t e);
    extern task t3(output s_t o);
  endclass
  function int pr::fmt(s_t row);
    s_t loc;
    loc = row;
    return loc.a;
  endfunction
  function int pr::f2(s_t row2, e_t e);
    return row2.b + e;
  endfunction
  task pr::t3(output s_t o);
    o = '0;
  endtask
endpackage
package q;
  import p::*;
  class u;
    pr x;
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w; pr z;
endmodule
