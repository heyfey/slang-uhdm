// § modStructMemberQualSpan214 — the qualified bound in a struct typedef used as a module port type and as a function formal type in a module
package cfg;
  parameter int W = 5;
endpackage
module top(input logic [4:0] i, output logic [4:0] o);
  typedef struct packed { logic [cfg::W-1:0] d; } p_t;
  function automatic p_t pass(p_t x); return x; endfunction
  p_t a;
  assign a.d = i;
  p_t b;
  assign b = pass(a);
  assign o = b.d;
endmodule
