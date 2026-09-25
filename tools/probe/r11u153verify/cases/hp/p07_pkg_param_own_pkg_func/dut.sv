// § constPathBaseAnyKind146
package p;
  typedef struct packed { int unsigned CTL; } b_t;
  parameter b_t B = '{CTL: 4};
  function automatic logic [B.CTL-1:0] f(logic [B.CTL-1:0] x); return x; endfunction
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  assign o = p::f(i);
endmodule
