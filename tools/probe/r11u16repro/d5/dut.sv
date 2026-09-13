// d5 — NEGATIVE CONTROLS.  None of these is a member read of a FUNCTION-BUILT
// struct parameter in a continuous assignment; none may move.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.base = 64'h1000;
    return r;
  endfunction
  localparam cfg_t PAT = '{n: 5, base: 64'h20};   // PATTERN-built, not a call
endpackage

module dut #(parameter int unsigned W = 7) (
    output logic [31:0] o_pat,
    output logic [31:0] o_int,
    output logic [31:0] o_var,
    output logic [31:0] o_net
);
  p::cfg_t v;                    // a struct VARIABLE, not a parameter
  assign v = p::build();
  assign o_pat = p::PAT.n;       // pattern-built base
  assign o_int = W;              // plain int parameter, no member
  assign o_var = v.n;            // member of a VARIABLE
  assign o_net = 32'd9;
endmodule
