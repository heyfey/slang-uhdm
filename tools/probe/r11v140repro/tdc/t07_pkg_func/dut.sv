// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  function automatic cfg_t mk(input int v); return cfg_t'(v); endfunction
  localparam cfg_t C = mk(3);
endpackage
module top(output logic o);
  assign o = p::C.b;
endmodule
