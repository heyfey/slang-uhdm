// § nonTrailIdxPathNestShape306
package pk;
  typedef struct packed { logic [3:0] k; logic [3:0][3:0] idx; } t_t;
  typedef struct packed { logic [7:0] f; } e_t;
  function automatic logic [7:0] pf(e_t sa [16], t_t t);
    return sa[t.k].f + sa[t.idx[2]].f;
  endfunction
endpackage
module top(input pk::t_t t, output logic [7:0] r);
  pk::e_t sa [16];
  assign r = pk::pf(sa, t);
endmodule
