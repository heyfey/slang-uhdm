// d7 — the SIGNED member.  adjustSize replaces the LHS typespec with the
// constant's OWN (the member's) and, when the LHS is unsigned, WRITES
// VpiSigned(false) onto that shared member typespec.  int_typespec::Compare
// reads VpiSigned, so this arm is where that mutation becomes visible.
package p;
  typedef struct packed { int s; int unsigned u; byte b; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.s = -3;
    r.u = 7;
    r.b = 8'h7f;
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic signed [31:0] o_ss,   // signed member into a SIGNED lhs
    output logic [31:0]        o_su,   // signed member into an UNSIGNED lhs
    output logic [31:0]        o_u,
    output logic [7:0]         o_b
);
  assign o_ss = CFG.s;
  assign o_su = CFG.s;
  assign o_u  = CFG.u;
  assign o_b  = CFG.b;
endmodule
