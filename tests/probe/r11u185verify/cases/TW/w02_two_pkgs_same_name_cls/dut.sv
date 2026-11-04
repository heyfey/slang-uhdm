// § tfArgClassMethodOrder176 § tfArgDefTopSplit176
package pa;
  typedef struct packed { logic [2:0] a; logic b; } s_t;
endpackage
package pb;
  typedef struct packed { logic [5:0] a; } s_t;
  function automatic int f(s_t x); return x.a; endfunction
endpackage
package pc;
  import pa::*;
  class k;
    function void m(s_t v); endfunction
    function void n(pb::s_t w); endfunction
  endclass
endpackage
module top;
  import pc::*;
  k o; int r;
  initial begin o = new; o.m('0); o.n('0); r = pb::f('0); end
endmodule
