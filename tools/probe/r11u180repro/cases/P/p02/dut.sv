// § pkgAggTfArgCloneFollows180
package p;
  typedef struct packed { int unsigned a; bit f; } u_t;
  function automatic u_t setc();
    u_t c; c.a = 7; c.f = 1'b1; return c;
  endfunction
  function automatic int unsigned get(u_t u);
    return u.a;
  endfunction
  localparam u_t U = setc();
endpackage
module child import p::*; (input logic x, output logic y);
  assign y = U.f ? x : 1'b0;
endmodule
module top import p::*; (input logic x, output logic y);
  child c (.x(x), .y(y));
endmodule
