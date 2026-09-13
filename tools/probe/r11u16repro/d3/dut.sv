// d3 — MODULE LOCALPARAM holder (struct_param_func_loop's shape), plus the
// WILDCARD-IMPORT copy of a package localparam read unqualified.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 2;
    r.base = 64'h8000;
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage

module dut (
    output logic [31:0] o_n,
    output logic [63:0] o_b,
    output logic [31:0] o_impn
);
  import p::*;
  localparam p::cfg_t CFG = p::build();
  localparam p::cfg_t IMP = C;      // materialized import copy of a pkg localparam
  assign o_n    = CFG.n;
  assign o_b    = CFG.base;
  assign o_impn = IMP.n;
endmodule
