package pa;
  typedef struct packed { logic [1:0] x; logic y; } s_t;
endpackage
package pb;
  import pa::*;
  function automatic logic f(s_t v);
    return v.y;
  endfunction
endpackage
module top(input pa::s_t i, output logic o);
  assign o = pb::f(i);
endmodule
