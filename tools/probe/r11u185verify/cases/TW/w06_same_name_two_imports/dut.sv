// § tdMoveKeyResolved176 § tfArgDefTopSplit176
package pa;
  typedef struct packed { logic [1:0] x; } s_t;
endpackage
package pz;
  typedef struct packed { logic [6:0] x; logic y; } s_t;
endpackage
package pq;
  import pz::*;
  function automatic int g(s_t v); return v.x; endfunction
endpackage
module top;
  import pa::*;
  function automatic int f(s_t v); return v.x; endfunction
  int r;
  initial r = f('0) + pq::g('0);
endmodule
