// d8 — THE ASSIGN TARGET KINDS.  writeCont_assign takes the LHS typespec from
// `bindVariable`, which only binds a PLAIN ref_obj Lhs in a module body; every
// select / concat / gen-local target is a different bind.  The member-slice
// constant carries its OWN typespec, so this arm measures whether the target
// kind changes the fold at all.
package p;
  typedef struct packed { int unsigned n; logic f; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.f    = 1'b1;
    r.base = 64'h1000;
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic [31:0] o_plain,
    output logic [63:0] o_ps,
    output logic [7:0]  o_bs,
    output logic [15:0] o_ca,
    output logic [15:0] o_cb,
    output logic [31:0] o_gen,
    output logic [31:0] o_list1,
    output logic [31:0] o_list2
);
  wire  [31:0] w_nda = CFG.n;         // NET-DECL assign
  assign o_plain      = CFG.n;        // plain ref lhs
  assign o_ps[31:0]   = CFG.n;        // PART-SELECT lhs
  assign o_ps[63:32]  = 32'd0;
  assign o_bs[3]      = CFG.f;        // BIT-SELECT lhs
  assign o_bs[7:4]    = 4'd0;
  assign o_bs[2:0]    = 3'd0;
  assign {o_ca, o_cb} = CFG.n;        // CONCAT lhs
  assign o_list1 = CFG.n, o_list2 = CFG.n;   // COMMA-LIST assign
  generate
    if (1) begin : g
      wire [31:0] gw;
      assign gw = CFG.n;              // gen-scope cont_assign
    end
  endgenerate
  assign o_gen = g.gw;
endmodule
